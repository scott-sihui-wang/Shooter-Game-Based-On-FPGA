--游戏主界面的程序设计
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED;
USE IEEE.STD_LOGIC_ARITH;

--游戏主界面的接口设计
ENTITY mainGame IS
	PORT(
		CLK_GAME:IN STD_LOGIC;--系统时钟
		EN_GAME:IN STD_LOGIC;--使能信号
		RST_GAME:IN STD_LOGIC;--重置信号
		RESUME_GAME:IN STD_LOGIC;--游戏重新开始
		BTN_SHOOT:IN STD_LOGIC;--射击按键
		BTN_SPEED_DOWN:IN STD_LOGIC;--靶减速按键
		BTN_SPEED_UP:IN STD_LOGIC;--靶加速按键
		CMP_GAME:OUT STD_LOGIC:='0';--游戏主界面进程完成标记
		STATE_GAME_TARGET:OUT INTEGER RANGE 0 TO 9:=0;--靶的位置信息
		STATE_GAME_BULLET:OUT INTEGER RANGE 0 TO 6:=0;--子弹的位置信息
		STATE_GAME_TIME_LEFT:OUT INTEGER RANGE 0 TO 40:=40;--倒计时信息
		STATE_GAME_SCORE:OUT INTEGER RANGE 0 TO 19:=0;--分数信息
		STATE_GAME_SHOOT:OUT STD_LOGIC:='0';--子弹是否正在飞行
		FLG_BULLET_MISS:OUT STD_LOGIC:='0';--未击中
		FLG_BULLET_GET:OUT STD_LOGIC:='0'--击中
	);
END ENTITY;

ARCHITECTURE game OF mainGame IS

	SIGNAL clkSecondsCnt:INTEGER RANGE 0 TO 49999999:=0;--倒计时分频计数器
	SIGNAL clkTargetCnt:INTEGER RANGE 0 TO 49999999:=0;--控制靶移动的分频计数器
	SIGNAL clkBulletCnt:INTEGER RANGE 0 TO 4999999:=0;--控制子弹飞行的0.1秒分频计数器
	SIGNAL clkButtonCheckCnt:INTEGER RANGE 0 TO 999999:=0;--控制每隔20毫秒进行一次按键检测
	SIGNAL targetSpeed:INTEGER RANGE 0 TO 49999999:=4999999;--控制靶移动速度的变量，决定靶移动分频器的分频数值
	SIGNAL targetPosition:INTEGER RANGE 0 TO 9:=0;--靶的位置信息
	SIGNAL bulletPosition:INTEGER RANGE 0 TO 6:=0;--子弹的位置信息
	SIGNAL timeLeft:INTEGER RANGE 0 TO 40:=40;--倒计时信息
	SIGNAL score:INTEGER RANGE 0 TO 19:=0;--分数信息
	SIGNAL flagBullet:STD_LOGIC:='0';--子弹是否处于飞行状态

BEGIN
	
	PROCESS(CLK_GAME)
	BEGIN
		IF CLK_GAME'EVENT AND CLK_GAME='1' THEN
			IF RST_GAME='0' THEN
				CMP_GAME<='0';
				clkSecondsCnt<=0;
				clkTargetCnt<=0;
				clkBulletCnt<=0;
				clkButtonCheckCnt<=0;
				targetSpeed<=4999999;
				targetPosition<=0;
				bulletPosition<=0;
				timeLeft<=40;
				score<=0;
				flagBullet<='0';
			ELSIF RESUME_GAME='1' THEN
				CMP_GAME<='0';
				clkSecondsCnt<=0;
				clkTargetCnt<=0;
				clkBulletCnt<=0;
				clkButtonCheckCnt<=0;
				targetSpeed<=4999999;
				targetPosition<=0;
				bulletPosition<=0;
				timeLeft<=40;
				score<=0;
				flagBullet<='0';
			--拨码开关关闭或者BTN0按下时，将内部信号重置，完成标记CMP_GAME清零
			ELSIF EN_GAME='0' THEN
				clkSecondsCnt<=0;
				clkTargetCnt<=0;
				clkBulletCnt<=0;
				clkButtonCheckCnt<=0;
				STATE_GAME_TARGET<=targetPosition;
				STATE_GAME_BULLET<=bulletPosition;
				STATE_GAME_TIME_LEFT<=timeLeft;
				STATE_GAME_SCORE<=score;
			--在正常游戏进程中，如果游戏主界面模块失能，说明该进程尚未开始或者已经结束，此时重置内部信号，但不改变完成标记CMP_GAME
			ELSE
				IF clkSecondsCnt=49999999 THEN--倒计时
					clkSecondsCnt<=0;
					IF timeLeft>0 THEN
						timeLeft<=timeLeft-1;
					END IF;
				ELSE
					clkSecondsCnt<=clkSecondsCnt+1;
				END IF;
				IF clkTargetCnt=targetSpeed THEN--控制靶的位置移动，由targetSpeed决定靶的移动频率，也就是靶的移动速度
					clkTargetCnt<=0;
					IF targetPosition=9 THEN--靶位置的循环滚动
						targetPosition<=0;
					ELSE
						targetPosition<=targetPosition+1;
					END IF;
				ELSE
					clkTargetCnt<=clkTargetCnt+1;
				END IF;
				IF flagBullet='1' THEN--当子弹处于飞行状态时
					IF clkBulletCnt=4999999 THEN--每隔0.1秒更新一次子弹位置
						clkBulletCnt<=0;
						IF bulletPosition<5 THEN
							bulletPosition<=bulletPosition+1;
						ELSIF bulletPosition=5 THEN
							bulletPosition<=6;--子弹到达底线时
							IF targetPosition=3 OR targetPosition=5 THEN--如果子弹击中靶边缘
								score<=score+2;--加2分
								FLG_BULLET_GET<='1';--击中标记信号置1
								FLG_BULLET_MISS<='0';
							ELSIF targetPosition=4 THEN--如果子弹击中靶中央
								score<=score+3;--加3分
								FLG_BULLET_GET<='1';--击中标记信号置1
								FLG_BULLET_MISS<='0';
							ELSE--如果子弹未击中
								FLG_BULLET_GET<='0';
								FLG_BULLET_MISS<='1';--未击中标记信号置1
							END IF;
						ELSE--子弹到达底线后，再经过0.1秒，子弹位置清零，设置flagBullet为0，结束对子弹的绘制，重新允许接受按键BTN1的信号
							flagBullet<='0';
							bulletPosition<=0;
						END IF;
					ELSE
						clkBulletCnt<=clkBulletCnt+1;
					END IF;
				ELSE--子弹未射出或者子弹飞行结束后，将控制子弹飞行的分频计数器清零，控制“命中”与“未命中”音效的信号清零
					clkBulletCnt<=0;
					FLG_BULLET_GET<='0';
					FLG_BULLET_MISS<='0';
				END IF;
				IF clkButtonCheckCnt=999999 THEN--每隔20毫秒检测一次BTN1、BTN6、BTN7的按键信息
--一般而言，按键抖动的时长在20毫秒以内。通过buttonProcessor模块，每次按键的输出信号都被转化为时长20毫秒的高电平方波信号。在这里，每隔20毫秒检测一次按键信息，恰好保证了每次按键信息都被检测到，且每个按键信息只被检测到一次，这就达到了按键消抖的目的
					clkButtonCheckCnt<=0;
					IF BTN_SPEED_UP='1' THEN--按下BTN7时，修改targetSpeed使得靶移动频率增高，即靶加速
						IF targetSpeed>100000 THEN
							targetSpeed<=targetSpeed-100000;
						END IF;
					ELSIF BTN_SPEED_DOWN='1' THEN--按下BTN6时，靶移动频率降低，即靶减速
						IF targetSpeed<24899999 THEN
							targetSpeed<=targetSpeed+100000;
						END IF;
					ELSIF flagBullet='0' AND BTN_SHOOT='1' THEN--点阵中没有子弹时，响应BTN1按键，将子弹飞行状态标记为1，表示子弹正在飞行
						flagBullet<='1';
					END IF;
				ELSE
					clkButtonCheckCnt<=clkButtonCheckCnt+1;
				END IF;
				IF timeLeft=0 OR score>=15 THEN--达到15分或者超过时限时，将完成标志置1，结束游戏主界面进程
					CMP_GAME<='1';
				END IF;
				--将内部信号赋值给接口
				STATE_GAME_TARGET<=targetPosition;
				STATE_GAME_BULLET<=bulletPosition;
				STATE_GAME_TIME_LEFT<=timeLeft;
				STATE_GAME_SCORE<=score;
				STATE_GAME_SHOOT<=flagBullet;
			END IF;
		END IF;
	END PROCESS;
	
END game;