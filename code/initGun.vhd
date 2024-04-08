--渐亮显示模块的程序设计
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED;
USE IEEE.STD_LOGIC_ARITH;

--渐亮显示模块的接口设计
ENTITY initGun IS
	PORT(
		CLK_INIT:IN STD_LOGIC;--系统时钟
		EN_INIT:IN STD_LOGIC;--使能信号
		RST_INIT:IN STD_LOGIC;--重置信号
		RESUME_INIT:IN STD_LOGIC;--游戏重新开始信号
		CMP_INIT:OUT STD_LOGIC:='0';--渐亮显示模块完成标记
		STATE_INIT:OUT INTEGER RANGE 0 TO 7:=0--渐亮显示模块的当前运行状态，控制点阵选通信号的占空比
	);
END ENTITY;

ARCHITECTURE initializer OF initGun IS
	
	SIGNAL clkCnt:INTEGER RANGE 0 TO 18749999;
	--将3秒时间分成8个阶段，每个时段亮度不同，为此设计分频计数器clkCnt
	SIGNAL stateCnt:INTEGER RANGE 0 TO 7;
	--记录渐亮显示模块的当前状态
	
BEGIN

	PROCESS(CLK_INIT)
	BEGIN
		IF CLK_INIT'EVENT AND CLK_INIT='1' THEN
			IF RST_INIT='0' THEN
				CMP_INIT<='0';
				clkCnt<=0;
				stateCnt<=0;
				STATE_INIT<=stateCnt;
			ELSIF RESUME_INIT='1' THEN
				CMP_INIT<='0';
				clkCnt<=0;
				stateCnt<=0;
				STATE_INIT<=stateCnt;
			--拨码开关关闭，或者BTN0按下时，重置渐亮显示模块，将内部信号置零，将完成标记CMP_INIT清零
			ELSIF EN_INIT='0' THEN
				clkCnt<=0;
				stateCnt<=0;
				STATE_INIT<=stateCnt;
			--在正常游戏进程中，如果渐亮显示模块失能，说明渐亮显示过程未开始或者已经结束，此时将渐亮显示模块的内部信号重置为0，同时保持完成标记CMP_INIT的值，不将其重置
			ELSIF EN_INIT='1' THEN--渐亮显示进程正在执行时
				IF clkCnt=18749999 THEN--每隔0.375秒
					clkCnt<=0;
					IF stateCnt<7 THEN--更新渐亮显示模块的内部状态
						stateCnt<=stateCnt+1;
					ELSE
						CMP_INIT<='1';
					END IF;
				ELSE
					clkCnt<=clkCnt+1;
				END IF;
				STATE_INIT<=stateCnt;--将内部状态输出，控制点阵扫描占空比
			END IF;		
		END IF;
	END PROCESS;

END initializer;