--音效播放模块的程序设计
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED;
USE IEEE.STD_LOGIC_ARITH;

--音效播放模块的接口设计
ENTITY musicPlayer IS
	PORT(
		CLK_BEEP:IN STD_LOGIC;--系统时钟
		FLG_PWR:IN STD_LOGIC;--拨码开关状态
		FLG_RESUME:IN STD_LOGIC;--是否重新开始游戏
		FLG_CHK:IN STD_LOGIC;
		STATE_CHK:IN INTEGER RANGE 0 TO 7;
		STATE_CHK_SCAN:IN INTEGER RANGE 0 TO 2;
		FLG_GAME:IN STD_LOGIC;
		FLG_BULLET_MISS:IN STD_LOGIC;
		FLG_BULLET_GET:IN STD_LOGIC;
		FLG_RESULT:IN STD_LOGIC;
		FLG_WIN:IN STD_LOGIC;
		--判断游戏处于哪个阶段，状态参数如何
		TONE_OUT:OUT STD_LOGIC--输出声音信号
	);
END musicPlayer;

ARCHITECTURE player OF musicPlayer IS
	
	SIGNAL toneFreq:INTEGER RANGE 0 TO 100000;
	SIGNAL toneCnt:INTEGER RANGE 0 TO 100000:=0;
	SIGNAL stateChk:INTEGER RANGE 0 TO 23;--自检音阶状态
	SIGNAL stateMiss:INTEGER RANGE 0 TO 4:=0;--未命中音效状态
	SIGNAL stateGet:INTEGER RANGE 0 TO 4:=0;--命中音效状态
	SIGNAL soundCnt:INTEGER RANGE 0 TO 3124999:=0;--十六分之一音符分频计数器
	SIGNAL musicCnt:INTEGER RANGE 0 TO 12499999:=0;--四分之一音符分频计数器
	SIGNAL gameMusicCnt:INTEGER RANGE 0 TO 23:=0;--游戏音乐状态
	SIGNAL winMusicCnt:INTEGER RANGE 0 TO 3:=0;--胜利音效状态
	SIGNAL loseMusicCnt:INTEGER RANGE 0 TO 3:=0;--失败音效状态
	SIGNAL beep:STD_LOGIC;--声音输出
		
BEGIN
	
	PROCESS(CLK_BEEP)
	BEGIN
		IF CLK_BEEP'EVENT AND CLK_BEEP='1' THEN
			IF FLG_PWR='0' OR FLG_RESUME='1' THEN--关闭拨码开关或BTN0按下时，状态清零，声音关闭
				toneCnt<=0;
				stateMiss<=0;
				stateGet<=0;
				soundCnt<=0;
				musicCnt<=0;
				gameMusicCnt<=0;
				winMusicCnt<=0;
				loseMusicCnt<=0;
				beep<='0';
			ELSIF FLG_CHK='1' THEN--自检时，根据自检模块的输出状态，依次输出低音、中音、高音音阶
				stateChk<=STATE_CHK_SCAN*8+STATE_CHK;
				CASE stateChk IS
					WHEN 0=>toneFreq<=95566;
					WHEN 1=>toneFreq<=85121;
					WHEN 2=>toneFreq<=75850;
					WHEN 3=>toneFreq<=71592;
					WHEN 4=>toneFreq<=63776;
					WHEN 5=>toneFreq<=56818;
					WHEN 6=>toneFreq<=50618;
					WHEN 7=>toneFreq<=47774;
					WHEN 8=>toneFreq<=47774;
					WHEN 9=>toneFreq<=42568;
					WHEN 10=>toneFreq<=37919;
					WHEN 11=>toneFreq<=35791;
					WHEN 12=>toneFreq<=31888;
					WHEN 13=>toneFreq<=28409;
					WHEN 14=>toneFreq<=25309;
					WHEN 15=>toneFreq<=23912;
					WHEN 16=>toneFreq<=23912;
					WHEN 17=>toneFreq<=21282;
					WHEN 18=>toneFreq<=18961;
					WHEN 19=>toneFreq<=17971;
					WHEN 20=>toneFreq<=15944;
					WHEN 21=>toneFreq<=14205;
					WHEN 22=>toneFreq<=12655;
					WHEN 23=>toneFreq<=11956;
				END CASE;
				IF toneCnt>=toneFreq THEN--设定蜂鸣器电平翻转的频率，即可实现相应的音高
					toneCnt<=0;
					beep<=NOT beep;
				ELSE
					toneCnt<=toneCnt+1;
				END IF;
			ELSIF FLG_GAME='1' THEN--在游戏过程中
				IF FLG_BULLET_MISS='0' AND FLG_BULLET_GET='0' AND stateMiss=0 AND stateGet=0 THEN--播放游戏背景音乐
					IF musicCnt=12499999 THEN--每个音符都是四分之一音符
						musicCnt<=0;
						IF gameMusicCnt=22 THEN
							gameMusicCnt<=0;
						ELSE
							gameMusicCnt<=gameMusicCnt+1;
						END IF;
					ELSE
						musicCnt<=musicCnt+1;
					END IF;
					CASE gameMusicCnt IS
						WHEN 0=>toneFreq<=47774;
						WHEN 1=>toneFreq<=63776;
						WHEN 2=>toneFreq<=47774;
						WHEN 3=>toneFreq<=37919;
						WHEN 4=>toneFreq<=47774;
						WHEN 5=>toneFreq<=37919;
						WHEN 6=>toneFreq<=31888;
						WHEN 7=>toneFreq<=23912;
						WHEN 8=>toneFreq<=25309;
						WHEN 9=>toneFreq<=28409;
						WHEN 10=>toneFreq<=31888;
						WHEN 11=>toneFreq<=31888;
						WHEN 12=>toneFreq<=35791;
						WHEN 13=>toneFreq<=37919;
						WHEN 14=>toneFreq<=47774;
						WHEN 15=>toneFreq<=63776;
						WHEN 16=>toneFreq<=56818;
						WHEN 17=>toneFreq<=47774;
						WHEN 18=>toneFreq<=35791;
						WHEN 19=>toneFreq<=37919;
						WHEN 20=>toneFreq<=47774;
						WHEN 21=>toneFreq<=28409;
						WHEN 22=>toneFreq<=31888;
						WHEN 23=>toneFreq<=0;
					END CASE;
					IF gameMusicCnt<23 THEN
						IF toneCnt>=toneFreq THEN
							toneCnt<=0;
							beep<=NOT beep;
						ELSE
							toneCnt<=toneCnt+1;
						END IF;
					ELSE
						beep<='0';
					END IF;
				ELSIF FLG_BULLET_MISS='1' OR stateMiss>0 THEN
				--子弹到达底线且未命中时，游戏主界面模块将FLG_BULLET_MISS置1，此时stateMiss的值为0，未命中音效开始播放；
				--在游戏主界面模块中，0.1秒后FLG_BULLET_MISS被清零，此时未命中音效并未播放完毕，由于stateMiss值大于0，因而未命中音效继续播放；
				--未命中音效播放完毕后，stateMiss被清零。未命中音效的播放时间为0.25秒，小于下一颗子弹从发射到飞行至底线的时间0.6秒，因而stateMiss被清零时，
				--FLG_BULLET_MISS与FLG_BULLET_GET均为0，此时未命中音效播放结束，游戏背景音效从断点处开始继续播放
					IF soundCnt=3124999 THEN
						soundCnt<=0;
						IF stateMiss=4 THEN
							stateMiss<=0;
						ELSE
							stateMiss<=stateMiss+1;
						END IF;
					ELSE
						soundCnt<=soundCnt+1;
					END IF;
					CASE stateMiss IS
						WHEN 0=>toneFreq<=47774;
						WHEN 1=>toneFreq<=63776;
						WHEN 2=>toneFreq<=75850;
						WHEN 3=>toneFreq<=95566;
						WHEN 4=>toneFreq<=0;
					END CASE;
					IF stateMiss<4 THEN
						IF toneCnt>=toneFreq THEN
							toneCnt<=0;
							beep<=NOT beep;
						ELSE
							toneCnt<=toneCnt+1;
						END IF;
					ELSE
						beep<='0';
					END IF;
				ELSIF FLG_BULLET_GET='1' OR stateGet>0 THEN--播放命中音效，原理与上面相同
					IF soundCnt=3124999 THEN
						soundCnt<=0;
						IF stateGet=4 THEN
							stateGet<=0;
						ELSE
							stateGet<=stateGet+1;
						END IF;
					ELSE
						soundCnt<=soundCnt+1;
					END IF;
					CASE stateGet IS
						WHEN 0=>toneFreq<=95566;
						WHEN 1=>toneFreq<=75850;
						WHEN 2=>toneFreq<=63776;
						WHEN 3=>toneFreq<=47774;
						WHEN 4=>toneFreq<=0;
					END CASE;
					IF stateGet<4 THEN
						IF toneCnt>=toneFreq THEN
							toneCnt<=0;
							beep<=NOT beep;
						ELSE
							toneCnt<=toneCnt+1;
						END IF;
					ELSE
						beep<='0';
					END IF;
				END IF;
			ELSIF FLG_RESULT='1' THEN--结果显示模块运行时
				IF FLG_WIN='1' THEN--如果游戏胜利
					IF musicCnt=12499999 THEN
						musicCnt<=0;
						IF winMusicCnt<3 THEN--播放胜利音效（3个音符），然后停止
							winMusicCnt<=winMusicCnt+1;
						END IF;
					ELSE
						musicCnt<=musicCnt+1;
					END IF;
					CASE winMusicCnt IS
						WHEN 0=>toneFreq<=47774;
						WHEN 1=>toneFreq<=31888;
						WHEN 2=>toneFreq<=23912;
						WHEN 3=>toneFreq<=0;
					END CASE;
					IF winMusicCnt<3 THEN
						IF toneCnt>=toneFreq THEN
							toneCnt<=0;
							beep<=NOT beep;
						ELSE
							toneCnt<=toneCnt+1;
						END IF;
					ELSE
						beep<='0';
					END IF;
				ELSIF FLG_WIN='0' THEN--如果游戏失败
					IF musicCnt=12499999 THEN
						musicCnt<=0;
						IF loseMusicCnt<3 THEN--播放失败音效（3个音符），然后停止
							loseMusicCnt<=loseMusicCnt+1;
						END IF;
					ELSE
						musicCnt<=musicCnt+1;
					END IF;
					CASE loseMusicCnt IS
						WHEN 0=>toneFreq<=23912;
						WHEN 1=>toneFreq<=31888;
						WHEN 2=>toneFreq<=47774;
						WHEN 3=>toneFreq<=0;
					END CASE;
					IF loseMusicCnt<3 THEN
						IF toneCnt>=toneFreq THEN
							toneCnt<=0;
							beep<=NOT beep;
						ELSE
							toneCnt<=toneCnt+1;
						END IF;
					ELSE
						beep<='0';
					END IF;
				END IF;
			ELSE--游戏的其余各阶段，状态清零，蜂鸣器不发声
				toneCnt<=0;
				stateMiss<=0;
				stateGet<=0;
				soundCnt<=0;
				musicCnt<=0;
				gameMusicCnt<=0;
				winMusicCnt<=0;
				loseMusicCnt<=0;
				beep<='0';
			END IF;
			TONE_OUT<=beep;
		END IF;
	END PROCESS;

END player;