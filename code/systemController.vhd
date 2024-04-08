--控制器的程序设计
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED;
USE IEEE.STD_LOGIC_ARITH;

--控制器的接口设计
ENTITY systemController IS
	PORT(
		CLK_SYS:IN STD_LOGIC;--系统时钟
		SW_PWR:IN STD_LOGIC;--拨码开关
		BTN_RESUME:IN STD_LOGIC;--BTN0是否按下

		--接收各模块过程是否完成的反馈信息，判断当前应当使能哪个模块
		CMP_CHK:IN STD_LOGIC;
		CMP_WT:IN STD_LOGIC;
		CMP_INIT:IN STD_LOGIC;
		CMP_GAME:IN STD_LOGIC;

		--各模块正在运行的标志信号，用于使能各模块
		FLG_CHK:OUT STD_LOGIC:='0';
		FLG_WT:OUT STD_LOGIC:='0';
		FLG_INIT:OUT STD_LOGIC:='0';
		FLG_GAME:OUT STD_LOGIC:='0';
		FLG_RESULT:OUT STD_LOGIC:='0';

		--将拨码开关的状态与BTN0的按键状态输出，用于控制各模块是否重置
		FLG_PWR:OUT STD_LOGIC:='0';
		FLG_RESUME:OUT STD_LOGIC:='0'
	);
END ENTITY;

ARCHITECTURE systemControl OF systemController IS	
BEGIN

	PROCESS(CLK_SYS)--响应拨码开关的状态与BTN0的状态，用于重置游戏进程模块；通过各游戏进程模块反馈的CMP信号，判断当前游戏进程，控制各游戏进程模块按照顺序使能与失能
	BEGIN
		IF SW_PWR='0' THEN--拨码开关关闭时
			FLG_CHK<='0';
			FLG_WT<='0';
			FLG_INIT<='0';
			FLG_GAME<='0';
			FLG_RESULT<='0';--令所有模块失能
			FLG_PWR<='0';--令所有模块重置到初始状态
			FLG_RESUME<='0';
		ELSIF SW_PWR='1' AND CMP_WT='1' AND BTN_RESUME='1' THEN
		--如果拨码开关打开，且游戏处于渐亮显示、游戏主界面、结果显示三个进程之一时，由控制器响应BTN0的按键信息
			FLG_GAME<='0';
			FLG_RESULT<='0';--按下BTN0时，令游戏主界面、结果显示两个模块失能
			FLG_PWR<='1';
			FLG_RESUME<='1';--同时令渐亮显示、游戏主界面、结果显示三个模块重置到初始状态
		ELSE--如果拨码开关打开，且没有BTN0用于发出“重新开始游戏”的命令
			--根据各模块反馈的信息判断游戏进程
			IF CMP_CHK='0' THEN--自检未完成时，自检模块使能，其它模块失能
				FLG_CHK<='1';
				FLG_WT<='0';
				FLG_INIT<='0';
				FLG_GAME<='0';
				FLG_RESULT<='0';
				FLG_PWR<='1';
				FLG_RESUME<='0';
			ELSIF CMP_WT='0' THEN--自检完成而待机未完成时，待机模块使能，其余模块失能
				FLG_CHK<='0';
				FLG_WT<='1';
				FLG_INIT<='0';
				FLG_GAME<='0';
				FLG_RESULT<='0';
				FLG_PWR<='1';
				FLG_RESUME<='0';
			ELSIF CMP_INIT='0' THEN--待机完成而渐亮显示未完成时，渐亮显示模块使能，其余模块失能
				FLG_CHK<='0';
				FLG_WT<='0';
				FLG_INIT<='1';
				FLG_GAME<='0';
				FLG_RESULT<='0';
				FLG_PWR<='1';
				FLG_RESUME<='0';
			ELSIF CMP_GAME='0' THEN--渐亮显示完成而游戏主界面未完成时，游戏主界面模块使能，其余模块失能
				FLG_CHK<='0';
				FLG_WT<='0';
				FLG_INIT<='0';
				FLG_GAME<='1';
				FLG_RESULT<='0';
				FLG_PWR<='1';
				FLG_RESUME<='0';
			ELSE--否则，结果显示模块使能，其余模块失能
				FLG_CHK<='0';
				FLG_WT<='0';
				FLG_INIT<='0';
				FLG_GAME<='0';
				FLG_RESULT<='1';
				FLG_PWR<='1';
				FLG_RESUME<='0';
			END IF;
		END IF;
	END PROCESS;
	
END systemControl;