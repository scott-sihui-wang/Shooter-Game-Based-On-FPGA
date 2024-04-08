--待机模块的程序设计
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED;
USE IEEE.STD_LOGIC_ARITH;

--待机模块的接口设计
ENTITY waitGame IS
	PORT(
		CLK_WT:IN STD_LOGIC;--系统时钟
		EN_WT:IN STD_LOGIC;--使能信号
		RST_WT:IN STD_LOGIC;--重置信号
		BTN_START:IN STD_LOGIC;--响应BTN0按下的状态，结束待机状态
		CMP_WT:OUT STD_LOGIC:='0'--待机结束的完成标记
	);
END ENTITY;

ARCHITECTURE waiting OF waitGame IS
BEGIN
	
	PROCESS(CLK_WT)
	BEGIN
		IF CLK_WT'EVENT AND CLK_WT='1' THEN
			IF RST_WT='0' THEN--拨码开关关闭时，将待机模块的完成标记清零
				CMP_WT<='0';
			ELSIF EN_WT='1' AND BTN_START='1' THEN--拨码开关打开时，响应BTN0的按键信息
				CMP_WT<='1';--BTN0按下时，将待机结束的完成标记置1，反馈给控制器，从而结束待机进程
			END IF;
		END IF;
	END PROCESS;
	
END waiting;