--自检模块的程序设计
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED;
USE IEEE.STD_LOGIC_ARITH;

--自检模块的接口设计
ENTITY autoCheck IS
	PORT(
		CLK_CHK:IN STD_LOGIC;--系统时钟
		EN_CHK:IN STD_LOGIC;--使能信号
		RST_CHK:IN STD_LOGIC;--重置信号
		CMP_CHK:OUT STD_LOGIC:='0';--将自检是否完成的信息反馈给控制器
		STATE_CHK:OUT INTEGER RANGE 0 TO 7:=0;--控制点阵与数码管的扫描
		STATE_CHK_SCAN:OUT INTEGER RANGE 0 TO 2:=0--扫描计数器，用于判断自检是否完成
	);
END ENTITY;

ARCHITECTURE check OF autoCheck IS
	
	SIGNAL clkCnt:INTEGER RANGE 0 TO 9999999;--5Hz分频计数器
	SIGNAL rowCnt:INTEGER RANGE 0 TO 7;--控制点阵行扫描与数码管扫描
	SIGNAL scanCnt:INTEGER RANGE 0 TO 3;--扫描次数的计数器
	
BEGIN
	
	PROCESS(CLK_CHK)
	BEGIN
		IF CLK_CHK'EVENT AND CLK_CHK='1' THEN
			IF RST_CHK='0' THEN--如果拨码开关关闭，将自检模块重置
				CMP_CHK<='0';--将自检完成标志信息清零，允许程序从头开始执行
			ELSIF RST_CHK='1' AND scanCnt=3 THEN--如果拨码开关打开，且扫描次数达到3次，说明自检完成
				CMP_CHK<='1';
			END IF;
			IF EN_CHK='0' THEN--自检模块失能后，将内部信号重置为0
				clkCnt<=0;
				rowCnt<=0;
				scanCnt<=0;
			--综上，自检正常完成时，自检模块失能但不重置，自检模块内部信号重置为0，而完成标记CMP_CHK保持为1，
			--此时控制器判断令待机、渐亮显示等后面的模块依次使能执行
			--拨码开关关闭，游戏进程被打断时，自检模块失能且重置。自检模块内部信号重置为0，完成标记CMP_CHK也清零
			--再次打开开关时，由于CMP_CHK清零，控制器判断令自检模块使能。
			--由于自检模块内部信号已经重置为0，因而自检模块可以重新开始扫描过程
			ELSE
				IF clkCnt=9999999 THEN--5Hz分频计数器循环计数
					clkCnt<=0;
					IF rowCnt=7 THEN--每隔0.2秒，更新rowCnt，rowCnt由0至7循环计数，表示当前扫描点阵哪一行
						rowCnt<=0;
						IF scanCnt<3 THEN--rowCnt每完成一次循环计数，令扫描计数scanCnt加一
							scanCnt<=scanCnt+1;
						END IF;
					ELSE
						rowCnt<=rowCnt+1;
					END IF;
				ELSE
					clkCnt<=clkCnt+1;
				END IF;
				STATE_CHK<=rowCnt;--将rowCnt与scanCnt输出，控制显示模块与音效模块
				IF scanCnt<3 THEN
					STATE_CHK_SCAN<=scanCnt;
				END IF;
			END IF;
		END IF;
	END PROCESS;
		
END check;