--按键信息处理模块的程序设计
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED;
USE IEEE.STD_LOGIC_ARITH;

--按键信息处理模块的接口设计
ENTITY buttonProcessor IS
	PORT(
		CLK_BTNP:IN STD_LOGIC;--系统时钟
		BTN0_IN:IN STD_LOGIC;--BTN0的按键信息
		BTN1_IN:IN STD_LOGIC;--BTN1的按键信息
		BTN6_IN:IN STD_LOGIC;--BTN6的按键信息
		BTN7_IN:IN STD_LOGIC;--BTN7的按键信息
		BTN_RESUME:OUT STD_LOGIC;--处理后的BTN0的按键信息
		BTN_SHOOT:OUT STD_LOGIC;--处理后的BTN1的按键信息
		BTN_SPEED_DOWN:OUT STD_LOGIC;--处理后的BTN6的按键信息
		BTN_SPEED_UP:OUT STD_LOGIC--处理后的BTN7的按键信息
	);
END ENTITY;

ARCHITECTURE buttonProcess OF buttonProcessor IS
	SIGNAL clkCnt:INTEGER RANGE 0 TO 999999:=0;
BEGIN
	
	PROCESS(CLK_BTNP)
	BEGIN
		IF CLK_BTNP'EVENT AND CLK_BTNP='1' THEN
			IF clkCnt=999999 THEN--每隔20毫秒，检测一次按键信息，这样，每次按键信息的输出都是时长为20毫秒的高电平方波信号
				clkCnt<=0;
				BTN_RESUME<=BTN0_IN;
				BTN_SHOOT<=BTN1_IN;
				BTN_SPEED_DOWN<=BTN6_IN;
				BTN_SPEED_UP<=BTN7_IN;
			ELSE
				clkCnt<=clkCnt+1;
			END IF;
		END IF;
	END PROCESS;
	
END buttonProcess;