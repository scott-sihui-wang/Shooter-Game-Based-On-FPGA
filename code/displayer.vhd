--显示模块的程序设计
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED;
USE IEEE.STD_LOGIC_ARITH;

--显示模块的接口设计
ENTITY displayer IS
	PORT(
		CLK_DISP:IN STD_LOGIC;--系统时钟
		FLG_PWR:IN STD_LOGIC;--拨码开关状态
		FLG_CHK:IN STD_LOGIC;
		FLG_WT:IN STD_LOGIC;
		FLG_INIT:IN STD_LOGIC;
		FLG_GAME:IN STD_LOGIC;
		FLG_RESULT:IN STD_LOGIC;
		--哪个模块处于运行状态
		FLG_WIN:IN STD_LOGIC;--结果显示的输赢情况
		FLG_BULLET:IN STD_LOGIC;--子弹是否处于飞行状态
		STATE_CHK:IN INTEGER RANGE 0 TO 7;--自检行扫描信息
		STATE_INIT:IN INTEGER RANGE 0 TO 7;--渐亮显示状态信息
		STATE_GAME_TARGET:IN INTEGER RANGE 0 TO 9;	--移动靶位置信息
		STATE_GAME_BULLET:IN INTEGER RANGE 0 TO 6;--子弹位置信息
		STATE_GAME_TIME_LEFT:IN INTEGER RANGE 0 TO 40;--游戏过程中的倒计时信息
		STATE_GAME_SCORE:IN INTEGER RANGE 0 TO 19;--游戏过程中的计分信息
		RESULT_TIME_LEFT:IN INTEGER RANGE 0 TO 40;--结果显示的剩余时间信息
		RESULT_SCORE:IN INTEGER RANGE 0 TO 19;--结果显示的总分信息
		LED0_OUT:OUT STD_LOGIC;--电源指示灯
		CAT_OUT:OUT STD_LOGIC_VECTOR(0 TO 7);--数码管选通信号
		DIGIT_OUT:OUT STD_LOGIC_VECTOR(0 TO 7);--数码管显示信号
		ROW_OUT:OUT STD_LOGIC_VECTOR(0 TO 7);--点阵行选通信号
		COLR_OUT:OUT STD_LOGIC_VECTOR(0 TO 7);--红色点阵列选通信号
		COLG_OUT:OUT STD_LOGIC_VECTOR(0 TO 7)--绿色点阵列选通信号
	);
END ENTITY;

ARCHITECTURE display OF displayer IS
	
	SIGNAL clkInitCnt:INTEGER RANGE 0 TO 799;--渐亮显示阶段控制扫描周期的分频计数器
	SIGNAL rowInitCnt:INTEGER RANGE 0 TO 99;--渐亮显示阶段控制行选通的分频计数器
	SIGNAL clkGameCnt:INTEGER RANGE 0 TO 199;--游戏过程中以及结果显示时，控制扫描周期的分频计数器
	SIGNAL rowGameCnt:INTEGER RANGE 0 TO 7;--游戏过程中以及结果显示时，控制选通信号的循环计数器
	SIGNAL digitTime1:INTEGER RANGE 0 TO 4;--倒计时十位数的十进制数值
	SIGNAL digitTime2:INTEGER RANGE 0 TO 9;--倒计时个位数的十进制数值
	SIGNAL digitScore1:INTEGER RANGE 0 TO 1;--分数十位数的十进制数值
	SIGNAL digitScore2:INTEGER RANGE 0 TO 9;--分数个位数的十进制数值
	SIGNAL binaryTime1:STD_LOGIC_VECTOR(0 TO 7);
	SIGNAL binaryTime2:STD_LOGIC_VECTOR(0 TO 7);
	SIGNAL binaryScore1:STD_LOGIC_VECTOR(0 TO 7);
	SIGNAL binaryScore2:STD_LOGIC_VECTOR(0 TO 7);--相应的译码信号
	SIGNAL clkSparkCnt:INTEGER RANGE 0 TO 24999999;--结果显示时，控制数码管每0.5秒闪烁一次的分频计数器
	
BEGIN
	
	PROCESS(CLK_DISP)
	BEGIN
		IF CLK_DISP'EVENT AND CLK_DISP='1' THEN
			IF FLG_PWR='0' THEN--拨码开关关闭时，LED0灭，数码管、点阵全灭
				LED0_OUT<='0';
				DIGIT_OUT<="00000000";
				CAT_OUT<="11111111";
				COLR_OUT<="00000000";
				COLG_OUT<="00000000";
				ROW_OUT<="11111111";
			ELSE
				LED0_OUT<='1';--拨码开关打开时，LED0点亮
				IF FLG_CHK='1' THEN--如果处于自检状态
					DIGIT_OUT<="11111111";--数码管显示“8.”
					COLR_OUT<="11111111";--红色点阵各列全部选通
					COLG_OUT<="00000000";--绿色点阵各列均不选通
					CASE STATE_CHK IS--根据自检模块输出的参数由0到7，决定红色点阵选通哪一行，以及数码管选通哪一位
						WHEN 0=>CAT_OUT<="11111110";ROW_OUT<="11111110";
						WHEN 1=>CAT_OUT<="11111101";ROW_OUT<="11111101";
						WHEN 2=>CAT_OUT<="11111011";ROW_OUT<="11111011";
						WHEN 3=>CAT_OUT<="11110111";ROW_OUT<="11110111";
						WHEN 4=>CAT_OUT<="11101111";ROW_OUT<="11101111";
						WHEN 5=>CAT_OUT<="11011111";ROW_OUT<="11011111";
						WHEN 6=>CAT_OUT<="10111111";ROW_OUT<="10111111";
						WHEN 7=>CAT_OUT<="01111111";ROW_OUT<="01111111";
					END CASE;
				ELSIF FLG_INIT='1' THEN--渐亮显示阶段
					DIGIT_OUT<="00000000";--关闭数码管
					CAT_OUT<="11111111";
					IF clkInitCnt=799 THEN
						clkInitCnt<=0;
					ELSE
						clkInitCnt<=clkInitCnt+1;
					END IF;
					IF rowInitCnt=99 THEN
						rowInitCnt<=0;
					ELSE
						rowInitCnt<=rowInitCnt+1;
					END IF;
					IF clkInitCnt>700-STATE_INIT*100 THEN--由渐亮显示模块的状态参数STATE_INIT决定点阵选通信号的占空比，STATE_INIT由0到7，选通时长逐渐增长，点阵显示逐渐变亮
						IF rowInitCnt>=50 THEN--交替选通点阵的第一行和第二行，完成射击枪的显示
							COLG_OUT<="00111000";
							COLR_OUT<="00000000";
							ROW_OUT<="01111111";
						ELSE
							COLG_OUT<="00010000";
							COLR_OUT<="00000000";
							ROW_OUT<="10111111";
						END IF;
					ELSE
						COLG_OUT<="00000000";
						COLR_OUT<="00000000";
						ROW_OUT<="11111111";
					END IF;
				ELSIF FLG_GAME='1' THEN--游戏主界面进程运行时
					IF clkGameCnt=199 THEN
						clkGameCnt<=0;
						IF rowGameCnt=7 THEN
							rowGameCnt<=0;
						ELSE
							rowGameCnt<=rowGameCnt+1;
						END IF;
					ELSE
						clkGameCnt<=clkGameCnt+1;
					END IF;
					digitTime1<=STATE_GAME_TIME_LEFT/10;--计算倒计时与分数的十位数字与个位数字
					digitTime2<=STATE_GAME_TIME_LEFT MOD 10;
					digitScore1<=STATE_GAME_SCORE/10;
					digitScore2<=STATE_GAME_SCORE MOD 10;
					CASE digitTime1 IS
						WHEN 4=>binaryTime1<="01100110";--完成译码
						WHEN 3=>binaryTime1<="11110010";
						WHEN 2=>binaryTime1<="11011010";
						WHEN 1=>binaryTime1<="01100000";
						WHEN 0=>binaryTime1<="11111100";
					END CASE;
					CASE digitTime2 IS
						WHEN 9=>binaryTime2<="11110110";
						WHEN 8=>binaryTime2<="11111110";
						WHEN 7=>binaryTime2<="11100000";
						WHEN 6=>binaryTime2<="10111110";
						WHEN 5=>binaryTime2<="10110110";
						WHEN 4=>binaryTime2<="01100110";
						WHEN 3=>binaryTime2<="11110010";
						WHEN 2=>binaryTime2<="11011010";
						WHEN 1=>binaryTime2<="01100000";
						WHEN 0=>binaryTime2<="11111100";
					END CASE;
					CASE digitScore1 IS
						WHEN 1=>binaryScore1<="01100000";
						WHEN 0=>binaryScore1<="11111100";
					END CASE;
					CASE digitScore2 IS
						WHEN 9=>binaryScore2<="11110110";
						WHEN 8=>binaryScore2<="11111110";
						WHEN 7=>binaryScore2<="11100000";
						WHEN 6=>binaryScore2<="10111110";
						WHEN 5=>binaryScore2<="10110110";
						WHEN 4=>binaryScore2<="01100110";
						WHEN 3=>binaryScore2<="11110010";
						WHEN 2=>binaryScore2<="11011010";
						WHEN 1=>binaryScore2<="01100000";
						WHEN 0=>binaryScore2<="11111100";
					END CASE;
					--rowGameCnt循环计数，依次扫描选通点阵第一行至第八行
					IF rowGameCnt=0 THEN--绘制点阵第一行，显示数码管第一位
						CAT_OUT<="11111110";
						DIGIT_OUT<=binaryTime1;
						ROW_OUT<="11111110";
						COLG_OUT<="00000000";
						IF STATE_GAME_BULLET=6 THEN--根据子弹位置与靶的位置分情况讨论
							CASE STATE_GAME_TARGET IS--既需要绘制靶也需要绘制子弹的情况
								WHEN 0=>COLR_OUT<="10010000";
								WHEN 1=>COLR_OUT<="11010000";
								WHEN 2=>COLR_OUT<="11110000";
								WHEN 3=>COLR_OUT<="01110000";
								WHEN 4=>COLR_OUT<="00111000";
								WHEN 5=>COLR_OUT<="00011100";
								WHEN 6=>COLR_OUT<="00011110";
								WHEN 7=>COLR_OUT<="00010111";
								WHEN 8=>COLR_OUT<="00010011";
								WHEN 9=>COLR_OUT<="00010001";
							END CASE;
						ELSE
							CASE STATE_GAME_TARGET IS--只需要绘制靶的情况
								WHEN 0=>COLR_OUT<="10000000";
								WHEN 1=>COLR_OUT<="11000000";
								WHEN 2=>COLR_OUT<="11100000";
								WHEN 3=>COLR_OUT<="01110000";
								WHEN 4=>COLR_OUT<="00111000";
								WHEN 5=>COLR_OUT<="00011100";
								WHEN 6=>COLR_OUT<="00001110";
								WHEN 7=>COLR_OUT<="00000111";
								WHEN 8=>COLR_OUT<="00000011";
								WHEN 9=>COLR_OUT<="00000001";
							END CASE;
						END IF;
					ELSIF rowGameCnt=1 THEN--点阵第二行，数码管第二位
						CAT_OUT<="11111101";
						DIGIT_OUT<=binaryTime2;
						ROW_OUT<="11111101";
						COLG_OUT<="00000000";
						IF STATE_GAME_BULLET=5 THEN--根据子弹位置决定是否绘制
							COLR_OUT<="00010000";
						ELSE
							COLR_OUT<="00000000";
						END IF;
					ELSIF rowGameCnt=2 THEN--以下以此类推
						CAT_OUT<="11111111";
						DIGIT_OUT<="00000000";
						ROW_OUT<="11111011";
						COLG_OUT<="00000000";
						IF STATE_GAME_BULLET=4 THEN
							COLR_OUT<="00010000";
						ELSE
							COLR_OUT<="00000000";
						END IF;
					ELSIF rowGameCnt=3 THEN
						CAT_OUT<="11111111";
						DIGIT_OUT<="00000000";
						ROW_OUT<="11110111";
						COLG_OUT<="00000000";
						IF STATE_GAME_BULLET=3 THEN
							COLR_OUT<="00010000";
						ELSE
							COLR_OUT<="00000000";
						END IF;
					ELSIF rowGameCnt=4 THEN
						CAT_OUT<="11111111";
						DIGIT_OUT<="00000000";
						ROW_OUT<="11101111";
						COLG_OUT<="00000000";
						IF STATE_GAME_BULLET=2 THEN
							COLR_OUT<="00010000";
						ELSE
							COLR_OUT<="00000000";
						END IF;
					ELSIF rowGameCnt=5 THEN
						CAT_OUT<="11111111";
						DIGIT_OUT<="00000000";
						ROW_OUT<="11011111";
						COLG_OUT<="00000000";
						IF STATE_GAME_BULLET=1 THEN
							COLR_OUT<="00010000";
						ELSE
							COLR_OUT<="00000000";
						END IF;
					ELSIF rowGameCnt=6 THEN
						CAT_OUT<="10111111";
						DIGIT_OUT<=binaryScore1;
						ROW_OUT<="10111111";
						COLG_OUT<="00010000";--点阵第七行，绘制射击枪枪口
						IF STATE_GAME_BULLET=0 AND FLG_BULLET='1' THEN--根据子弹发射状态决定是否绘制子弹
							COLR_OUT<="00010000";
						ELSE
							COLR_OUT<="00000000";
						END IF;
					ELSIF rowGameCnt=7 THEN
						CAT_OUT<="01111111";
						DIGIT_OUT<=binaryScore2;
						ROW_OUT<="01111111";
						COLG_OUT<="00111000";--点阵第八行，绘制射击枪枪体
						COLR_OUT<="00000000";
					END IF;
				ELSIF FLG_RESULT='1' THEN--结果显示模块
					IF clkGameCnt=199 THEN--每200个系统时钟周期，更新一次数码管及点阵的选通位置。更新频率不宜过高，否则由于时钟沿的不同步，可能会出现显示效果的错误
						clkGameCnt<=0;
						IF rowGameCnt=7 THEN
							rowGameCnt<=0;
						ELSE
							rowGameCnt<=rowGameCnt+1;
						END IF;
					ELSE
						clkGameCnt<=clkGameCnt+1;
					END IF;
					IF clkSparkCnt=24999999 THEN
						clkSparkCnt<=0;
					ELSE
						clkSparkCnt<=clkSparkCnt+1;
					END IF;
					digitTime1<=RESULT_TIME_LEFT/10;--生成时间与分数的个位数字、十位数字信息
					digitTime2<=RESULT_TIME_LEFT MOD 10;
					digitScore1<=RESULT_SCORE/10;
					digitScore2<=RESULT_SCORE MOD 10;
					CASE digitTime1 IS--数字译码
						WHEN 4=>binaryTime1<="01100110";
						WHEN 3=>binaryTime1<="11110010";
						WHEN 2=>binaryTime1<="11011010";
						WHEN 1=>binaryTime1<="01100000";
						WHEN 0=>binaryTime1<="11111100";
					END CASE;
					CASE digitTime2 IS
						WHEN 9=>binaryTime2<="11110110";
						WHEN 8=>binaryTime2<="11111110";
						WHEN 7=>binaryTime2<="11100000";
						WHEN 6=>binaryTime2<="10111110";
						WHEN 5=>binaryTime2<="10110110";
						WHEN 4=>binaryTime2<="01100110";
						WHEN 3=>binaryTime2<="11110010";
						WHEN 2=>binaryTime2<="11011010";
						WHEN 1=>binaryTime2<="01100000";
						WHEN 0=>binaryTime2<="11111100";
					END CASE;
					CASE digitScore1 IS
						WHEN 1=>binaryScore1<="01100000";
						WHEN 0=>binaryScore1<="11111100";
					END CASE;
					CASE digitScore2 IS
						WHEN 9=>binaryScore2<="11110110";
						WHEN 8=>binaryScore2<="11111110";
						WHEN 7=>binaryScore2<="11100000";
						WHEN 6=>binaryScore2<="10111110";
						WHEN 5=>binaryScore2<="10110110";
						WHEN 4=>binaryScore2<="01100110";
						WHEN 3=>binaryScore2<="11110010";
						WHEN 2=>binaryScore2<="11011010";
						WHEN 1=>binaryScore2<="01100000";
						WHEN 0=>binaryScore2<="11111100";
					END CASE;
					IF rowGameCnt=0 THEN--数码管、点阵逐位、逐行扫描
						DIGIT_OUT<=binaryTime1;
						ROW_OUT<="11111110";
						IF FLG_WIN='1' THEN
							CAT_OUT<="11111110";
							COLR_OUT<="00000000";--胜利时，红色点阵关闭，绿色点阵绘制对勾
							COLG_OUT<="00000001";
						ELSE
							IF clkSparkCnt<12500000 THEN--失败时，数码管时间信息闪烁
								CAT_OUT<="11111110";
							ELSE
								CAT_OUT<="11111111";
							END IF;
							COLR_OUT<="10000001";
							COLG_OUT<="00000000";
						END IF;
					--以下以此类推
					ELSIF rowGameCnt=1 THEN
						DIGIT_OUT<=binaryTime2;
						ROW_OUT<="11111101";
						IF FLG_WIN='1' THEN
							CAT_OUT<="11111101";
							COLR_OUT<="00000000";
							COLG_OUT<="00000010";
						ELSE
							IF clkSparkCnt<12500000 THEN
								CAT_OUT<="11111101";
							ELSE
								CAT_OUT<="11111111";
							END IF;
							COLR_OUT<="01000010";
							COLG_OUT<="00000000";
						END IF;
					ELSIF rowGameCnt=2 THEN
						CAT_OUT<="11111111";
						DIGIT_OUT<="00000000";
						COLG_OUT<="00000000";
						ROW_OUT<="11111011";
						IF FLG_WIN='1' THEN
							COLR_OUT<="00000000";
						ELSE
							COLR_OUT<="00100100";
						END IF;
					ELSIF rowGameCnt=3 THEN
						CAT_OUT<="11111111";
						DIGIT_OUT<="00000000";
						ROW_OUT<="11110111";
						IF FLG_WIN='1' THEN
							COLR_OUT<="00000000";
							COLG_OUT<="00000100";
						ELSE
							COLR_OUT<="00011000";
							COLG_OUT<="00000000";
						END IF;
					ELSIF rowGameCnt=4 THEN
						CAT_OUT<="11111111";
						DIGIT_OUT<="00000000";
						ROW_OUT<="11101111";
						IF FLG_WIN='1' THEN
							COLR_OUT<="00000000";
							COLG_OUT<="10000000";
						ELSE
							COLR_OUT<="00011000";
							COLG_OUT<="00000000";
						END IF;
					ELSIF rowGameCnt=5 THEN
						CAT_OUT<="11111111";
						DIGIT_OUT<="00000000";
						ROW_OUT<="11011111";
						IF FLG_WIN='1' THEN
							COLR_OUT<="00000000";
							COLG_OUT<="01001000";
						ELSE
							COLR_OUT<="00100100";
							COLG_OUT<="00000000";
						END IF;
					ELSIF rowGameCnt=6 THEN
						DIGIT_OUT<=binaryScore1;
						ROW_OUT<="10111111";
						IF FLG_WIN='1' THEN
							IF clkSparkCnt<12500000 THEN
								CAT_OUT<="10111111";
							ELSE
								CAT_OUT<="11111111";
							END IF;
							COLR_OUT<="00000000";
							COLG_OUT<="00100000";
						ELSE
							CAT_OUT<="10111111";
							COLR_OUT<="01000010";
							COLG_OUT<="00000000";
						END IF;
					ELSIF rowGameCnt=7 THEN
						DIGIT_OUT<=binaryScore2;
						ROW_OUT<="01111111";
						IF FLG_WIN='1' THEN
							IF clkSparkCnt<12500000 THEN--胜利时，分数闪烁显示
								CAT_OUT<="01111111";
							ELSE
								CAT_OUT<="11111111";
							END IF;
							COLR_OUT<="00000000";
							COLG_OUT<="00010000";
						ELSE
							CAT_OUT<="01111111";
							COLR_OUT<="10000001";
							COLG_OUT<="00000000";
						END IF;
					END IF;
				ELSE
					CAT_OUT<="11111111";
					DIGIT_OUT<="00000000";
					ROW_OUT<="11111111";
					COLG_OUT<="00000000";
					COLR_OUT<="00000000";
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
END display;