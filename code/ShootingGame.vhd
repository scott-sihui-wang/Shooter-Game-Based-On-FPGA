--��������ļ�
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED;
USE IEEE.STD_LOGIC_ARITH;

--�����·�Ķ���ӿ�
ENTITY shootingGame IS
	PORT(
		clk:IN STD_LOGIC;--ϵͳ50MHzʱ��
		sw7:IN STD_LOGIC;--���뿪��SW7
		btn0:IN STD_LOGIC;--����BTN0��������Ϸ��ʼ
		btn1:IN STD_LOGIC;--����BTN1���������
		btn6:IN STD_LOGIC;--����BTN6�����ưе��ƶ��ٶȽ���
		btn7:IN STD_LOGIC;--����BTN7�����ưе��ƶ��ٶ����
		led0:OUT STD_LOGIC;--LED0������ָʾ��
		cat:OUT STD_LOGIC_VECTOR(0 TO 7);--����ܵ�ѡͨ�ź�
		digit:OUT STD_LOGIC_VECTOR(0 TO 7);--�߶������AA~AG�Լ�AP�ĵ�ƽ�ź�
		row:OUT STD_LOGIC_VECTOR(0 TO 7);--������ѡͨ�ź�
		colr:OUT STD_LOGIC_VECTOR(0 TO 7);--��ɫ������ѡͨ�ź�
		colg:OUT STD_LOGIC_VECTOR(0 TO 7);--��ɫ������ѡͨ�ź�
		beep:OUT STD_LOGIC--�������ź�
	);
END ENTITY;

--��ģ��Ľӿ��Լ��ӿ�֮������߹�ϵ
ARCHITECTURE gameDesign OF shootingGame IS
	
	SIGNAL SIG_BTN_RESUME:STD_LOGIC;
	SIGNAL SIG_BTN_SHOOT:STD_LOGIC;
	SIGNAL SIG_BTN_SPEED_DOWN:STD_LOGIC;
	SIGNAL SIG_BTN_SPEED_UP:STD_LOGIC;
	SIGNAL SIG_CMP_CHK:STD_LOGIC;
	SIGNAL SIG_CMP_WT:STD_LOGIC;
	SIGNAL SIG_CMP_INIT:STD_LOGIC;
	SIGNAL SIG_CMP_GAME:STD_LOGIC;
	SIGNAL SIG_FLG_CHK:STD_LOGIC;
	SIGNAL SIG_FLG_WT:STD_LOGIC;
	SIGNAL SIG_FLG_INIT:STD_LOGIC;
	SIGNAL SIG_FLG_GAME:STD_LOGIC;
	SIGNAL SIG_FLG_RESULT:STD_LOGIC;
	SIGNAL SIG_FLG_PWR:STD_LOGIC;
	SIGNAL SIG_FLG_RESUME:STD_LOGIC;
	SIGNAL SIG_FLG_WIN:STD_LOGIC;
	SIGNAL SIG_FLG_BULLET:STD_LOGIC;
	SIGNAL SIG_STATE_CHK:INTEGER RANGE 0 TO 7;
	SIGNAL SIG_STATE_CHK_SCAN:INTEGER RANGE 0 TO 2;
	SIGNAL SIG_STATE_INIT:INTEGER RANGE 0 TO 7;
	SIGNAL SIG_STATE_GAME_TARGET:INTEGER RANGE 0 TO 9;
	SIGNAL SIG_STATE_GAME_BULLET:INTEGER RANGE 0 TO 6;
	SIGNAL SIG_STATE_GAME_TIME_LEFT:INTEGER RANGE 0 TO 40;
	SIGNAL SIG_STATE_GAME_SCORE:INTEGER RANGE 0 TO 19;
	SIGNAL SIG_RESULT_TIME_LEFT:INTEGER RANGE 0 TO 40;
	SIGNAL SIG_RESULT_SCORE:INTEGER RANGE 0 TO 19;
	SIGNAL SIG_FLG_BULLET_MISS:STD_LOGIC;
	SIGNAL SIG_FLG_BULLET_GET:STD_LOGIC;

	--�������Ľӿ����		
	COMPONENT systemController
		PORT(
			CLK_SYS:IN STD_LOGIC;--ϵͳ50MHzʱ���ź�
			SW_PWR:IN STD_LOGIC;--���뿪�ص�״̬
			BTN_RESUME:IN STD_LOGIC;--����BTN0�������¿�ʼ��Ϸʱ�����ź���1��������0
			CMP_CHK:IN STD_LOGIC;--�Լ������ɱ���źţ��Լ������ɺ����Լ�ģ�鷴����������
			CMP_WT:IN STD_LOGIC;--����������ɱ���źţ������������ɴ���ģ�鷴����������
			CMP_INIT:IN STD_LOGIC;--������ʾ������ɱ���źţ�������ʾ�������ɽ�����ʾģ�鷴����������
			CMP_GAME:IN STD_LOGIC;--��Ϸ������ɱ���źţ���Ϸ����������Ϸ������ģ�鷴����������
			FLG_CHK:OUT STD_LOGIC;--�Լ�ģ������ִ�еı���źţ����ź�ʹ���Լ�ģ��
			FLG_WT:OUT STD_LOGIC;--����ģ������ִ�еı���źţ����ź�ʹ�ܴ���ģ��
			FLG_INIT:OUT STD_LOGIC;--������ʾģ������ִ�еı���źţ����ź�ʹ�ܽ�����ʾģ��
			FLG_GAME:OUT STD_LOGIC;--��Ϸ����������ִ�еı���źţ����ź�ʹ����Ϸ������ģ��
			FLG_RESULT:OUT STD_LOGIC;--�����ʾ��������ִ�еı���źţ����ź�ʹ�ܽ����ʾģ��
			FLG_PWR:OUT STD_LOGIC;--���뿪��״̬��ǣ��ɿ�����ͨ�����źſ��Ƹ���ģ�������
			FLG_RESUME:OUT STD_LOGIC--����BTN0�������¿�ʼ��Ϸʱ�����������ô˱�־�źſ��ƽ�����ʾ����Ϸ������������ʾģ�������
		);
	END COMPONENT;

	--�Լ�ģ��Ľӿ����
	COMPONENT autoCheck
		PORT(
			CLK_CHK:IN STD_LOGIC;--ϵͳʱ���ź�
			EN_CHK:IN STD_LOGIC;--�Լ�ʹ���źţ���FLG_CHK����
			RST_CHK:IN STD_LOGIC;--�Լ�ģ�������źţ���FLG_PWR����
			CMP_CHK:OUT STD_LOGIC;--�Լ������ɱ���źţ����ڷ�����������
			STATE_CHK:OUT INTEGER RANGE 0 TO 7;--��ǰɨ�赽�ڼ����Լ��ڼ�������ܣ����ڿ�����ʾģ���Լ���Ƶ����ģ��
			STATE_CHK_SCAN:OUT INTEGER RANGE 0 TO 2--��ǰ��ɵ�ɨ����������������ж��Լ��Ƿ����
		);
	END COMPONENT;

	--����ģ��Ľӿ����
	COMPONENT waitGame
		PORT(
			CLK_WT:IN STD_LOGIC;--ϵͳʱ���ź�
			EN_WT:IN STD_LOGIC;--����ʹ���źţ���FLG_WT����
			RST_WT:IN STD_LOGIC;--����ģ�������źţ���FLG_PWR����
			BTN_START:IN STD_LOGIC;--����BTN0���µ��źţ��жϴ��������Ƿ����
			CMP_WT:OUT STD_LOGIC--�����������ʱ�������ź���1��������������
		);
	END COMPONENT;

	--������ʾģ��Ľӿ����
	COMPONENT initGun
		PORT(
			CLK_INIT:IN STD_LOGIC;--ϵͳʱ���ź�
			EN_INIT:IN STD_LOGIC;--������ʾģ��ʹ���źţ���FLG_INIT����
			RST_INIT:IN STD_LOGIC;--������ʾģ�������źţ���FLG_PWR����
			RESUME_INIT:IN STD_LOGIC;--BTN0�������¿�ʼ��Ϸʱ�����ý�����ʾģ��
			CMP_INIT:OUT STD_LOGIC;--������ʾ������ɺ󣬽����ź���1������������
			STATE_INIT:OUT INTEGER RANGE 0 TO 7--�ڽ�����ʾ�Ĳ�ͬ�׶Σ��˲�����0��7�仯���ɴ˿��Ƶ���ѡͨ�źŵ�ռ�ձ�
		);
	END COMPONENT;

	--��Ϸ������ģ��Ľӿ����
	COMPONENT mainGame
		PORT(
			CLK_GAME:IN STD_LOGIC;--ϵͳʱ���ź�
			EN_GAME:IN STD_LOGIC;--��Ϸ������ģ��ʹ���źţ���FLG_GAME����
			RST_GAME:IN STD_LOGIC;--��Ϸ������ģ�������źţ���FLG_PWR����
			RESUME_GAME:IN STD_LOGIC;--BTN0�������¿�ʼ��Ϸʱ��������Ϸ������ģ��
			BTN_SHOOT:IN STD_LOGIC;--����BTN1���µ�����ź�
			BTN_SPEED_DOWN:IN STD_LOGIC;--����BTN6���µİ��ټ����ź�
			BTN_SPEED_UP:IN STD_LOGIC;--����BTN7���µİ��������ź�
			CMP_GAME:OUT STD_LOGIC;--��Ϸ����ʱ�������ź���1��������������
			STATE_GAME_TARGET:OUT INTEGER RANGE 0 TO 9;--�˲������ڼ�¼�ƶ��е�λ����Ϣ����ʾģ����ݴ˲������Ƶ���
			STATE_GAME_BULLET:OUT INTEGER RANGE 0 TO 6;--�˲������ڼ�¼�ӵ���λ����Ϣ����ʾģ����ݴ˲������Ƶ���
			STATE_GAME_TIME_LEFT:OUT INTEGER RANGE 0 TO 40;--�˲������ڵ���ʱ����ʾģ����ݴ˲������������
			STATE_GAME_SCORE:OUT INTEGER RANGE 0 TO 19;--�˲������ڼƷ֣���ʾģ����ݴ˲������������
			STATE_GAME_SHOOT:OUT STD_LOGIC;--�˲������ڱ�ʾ�ӵ��Ƿ��ڷ���״̬����1ʱ����ʾ�ӵ����ڷ��У���ʱ��ʾģ������ӵ��켣����Ϸģ�鲻����ӦBTN1����������0ʱ����ʾû���ӵ��������ʱ��ʾģ�鲻�����ӵ�����Ϸģ���ܹ���ӦBTN1���������
			FLG_BULLET_MISS:OUT STD_LOGIC;--�ӵ�δ���еı���źţ����ڿ�����Ч����ģ��
			FLG_BULLET_GET:OUT STD_LOGIC--�ӵ����еı���źţ����ڿ�����Ч����ģ��			
		);
	END COMPONENT;

	--�����ʾģ��Ľӿ����
	COMPONENT result
		PORT(
			CLK_RESULT:IN STD_LOGIC;--ϵͳʱ��
			EN_RESULT:IN STD_LOGIC;--�����ʾģ���ʹ���źţ���FLG_RESULT����
			STATE_GAME_TIME_LEFT:IN INTEGER RANGE 0 TO 40;--������Ϸ������ģ��ĵ���ʱ��Ϣ����ʾ��Ϸ����ʱ��ʣ��ʱ��
			STATE_GAME_SCORE:IN INTEGER RANGE 0 TO 19;--������Ϸ������ģ��ļƷ���Ϣ����ʾ��Ϸ����ʱ���ܷ�
			FLG_WIN:OUT STD_LOGIC;--��ʾ��Ϸʤ�������ڿ��Ƶ������ʾ
			RESULT_TIME_LEFT:OUT INTEGER RANGE 0 TO 40;--�����Ϸʣ��ʱ�䣬�����������ʾ
			RESULT_SCORE:OUT INTEGER RANGE 0 TO 19--�����Ϸ����ܷ֣������������ʾ
		);
	END COMPONENT;

	--��ʾģ��Ľӿ����
	COMPONENT displayer
		PORT(
			CLK_DISP:IN STD_LOGIC;--ϵͳʱ��
			FLG_PWR:IN STD_LOGIC;--���뿪���Ƿ��
			FLG_CHK:IN STD_LOGIC;--�Լ�ģ���Ƿ���������
			FLG_WT:IN STD_LOGIC;--����ģ���Ƿ���������
			FLG_INIT:IN STD_LOGIC;--������ʾģ���Ƿ���������
			FLG_GAME:IN STD_LOGIC;--��Ϸ������ģ���Ƿ���������
			FLG_RESULT:IN STD_LOGIC;--�����ʾģ���Ƿ���������
			FLG_WIN:IN STD_LOGIC;--��Ϸ�������Ӯ���
			--������Ϣ�����ж���Ϸ�����ĸ����̣��Ӷ�������ʾģ�������Ӧ����ʾ
			FLG_BULLET:IN STD_LOGIC;--��ʾ�ӵ��Ƿ����ڷ��У�������ʾģ���Ƿ�����ӵ��켣
			STATE_CHK:IN INTEGER RANGE 0 TO 7;--��ʾ�Լ����������ɨ��ĵ���������ܵĶ�λ��Ϣ�����ڿ���ѡͨ��Ӧ�ĵ������������
			STATE_INIT:IN INTEGER RANGE 0 TO 7;--��ʾ������ʾ�����д��ں���״̬�����ڿ��Ƶ�����ѡͨ�źŵ�ռ�ձ�
			STATE_GAME_TARGET:IN INTEGER RANGE 0 TO 9;--ͨ���ƶ���λ����Ϣ���Ƶ������
			STATE_GAME_BULLET:IN INTEGER RANGE 0 TO 6;--ͨ���ӵ�����λ����Ϣ���Ƶ������
			STATE_GAME_TIME_LEFT:IN INTEGER RANGE 0 TO 40;--������Ϸʣ��ʱ�䣬�����������ʾ
			STATE_GAME_SCORE:IN INTEGER RANGE 0 TO 19;--���յ÷���Ϣ�������������ʾ
			RESULT_TIME_LEFT:IN INTEGER RANGE 0 TO 40;--������Ϸ���������Ϸʣ��ʱ�䣬����������Ƿ���˸��ʾ
			RESULT_SCORE:IN INTEGER RANGE 0 TO 19;--������Ϸ��������ܵ÷���Ϣ������������Ƿ���˸��ʾ
			LED0_OUT:OUT STD_LOGIC;--����FLG_PWR���ô��źţ���������ָʾ���Ƿ����
			CAT_OUT:OUT STD_LOGIC_VECTOR(0 TO 7);--���������ѡͨ
			DIGIT_OUT:OUT STD_LOGIC_VECTOR(0 TO 7);--�����������ʾ
			ROW_OUT:OUT STD_LOGIC_VECTOR(0 TO 7);--���Ƶ�����ѡͨ
			COLR_OUT:OUT STD_LOGIC_VECTOR(0 TO 7);--���ƺ�ɫ������ѡͨ
			COLG_OUT:OUT STD_LOGIC_VECTOR(0 TO 7)--������ɫ������ѡͨ
		);
	END COMPONENT;

	--��������ģ��Ľӿ����
	COMPONENT buttonProcessor
		PORT(
			CLK_BTNP:IN STD_LOGIC;--ϵͳʱ��
			BTN0_IN:IN STD_LOGIC;--����BTN0�İ����ź�
			BTN1_IN:IN STD_LOGIC;--����BTN1�İ����ź�
			BTN6_IN:IN STD_LOGIC;--����BTN6�İ����ź�
			BTN7_IN:IN STD_LOGIC;--����BTN7�İ����ź�
			BTN_RESUME:OUT STD_LOGIC;--�����������BTN0�Ŀ�ʼ��Ϸ�������¿�ʼ��Ϸ���ź�
			BTN_SHOOT:OUT STD_LOGIC;--�����������BTN1������ź�
			BTN_SPEED_DOWN:OUT STD_LOGIC;--�����������BTN6�İм����ź�
			BTN_SPEED_UP:OUT STD_LOGIC--�����������BTN7�İм����ź�
		);
	END COMPONENT;

	--��Ч����ģ��Ľӿ����
	COMPONENT musicPlayer
		PORT(
			CLK_BEEP:IN STD_LOGIC;--ϵͳʱ��
			FLG_PWR:IN STD_LOGIC;--���뿪���Ƿ��
			FLG_RESUME:IN STD_LOGIC;--�Ƿ����¿�ʼ��Ϸ
			FLG_CHK:IN STD_LOGIC;--��Ϸ�Ƿ����Լ�״̬
			STATE_CHK:IN INTEGER RANGE 0 TO 7;--�Լ�׶Σ����ݴ��źſ��Ʒ����������ײ���
			STATE_CHK_SCAN:IN INTEGER RANGE 0 TO 2;--�Լ�׶Σ����ݴ��źſ��Ʒ�������������Ϣ
			FLG_GAME:IN STD_LOGIC;--�Ƿ�����Ϸ�����������״̬�����Ʋ�����Ϸ��������
			FLG_BULLET_MISS:IN STD_LOGIC;--���Ʋ��š�δ���С���Ч
			FLG_BULLET_GET:IN STD_LOGIC;--���Ʋ��š����С���Ч
			FLG_RESULT:IN STD_LOGIC;--�Ƿ��ڽ����ʾ����
			FLG_WIN:IN STD_LOGIC;--�ж���Ϸ�������Ӯ�����Ʋ�����Ӧ��Ч
			TONE_OUT:OUT STD_LOGIC--ʵ����������ź�
		);
	END COMPONENT;
	
BEGIN

	--��ģ��ӿڼ�����߷�ʽ
	u1:systemController PORT MAP(
		CLK_SYS=>clk,
		SW_PWR=>sw7,
		BTN_RESUME=>SIG_BTN_RESUME,
		CMP_CHK=>SIG_CMP_CHK,
		CMP_WT=>SIG_CMP_WT,
		CMP_INIT=>SIG_CMP_INIT,
		CMP_GAME=>SIG_CMP_GAME,
		FLG_CHK=>SIG_FLG_CHK,
		FLG_WT=>SIG_FLG_WT,
		FLG_INIT=>SIG_FLG_INIT,
		FLG_GAME=>SIG_FLG_GAME,
		FLG_RESULT=>SIG_FLG_RESULT,
		FLG_PWR=>SIG_FLG_PWR,
		FLG_RESUME=>SIG_FLG_RESUME
	);

	u2:autoCheck PORT MAP(
		CLK_CHK=>clk,
		EN_CHK=>SIG_FLG_CHK,
		RST_CHK=>SIG_FLG_PWR,
		CMP_CHK=>SIG_CMP_CHK,
		STATE_CHK=>SIG_STATE_CHK,
		STATE_CHK_SCAN=>SIG_STATE_CHK_SCAN
	);
	
	u3:waitGame PORT MAP(
		CLK_WT=>clk,
		EN_WT=>SIG_FLG_WT,
		RST_WT=>SIG_FLG_PWR,
		BTN_START=>SIG_BTN_RESUME,
		CMP_WT=>SIG_CMP_WT
	);
	
	u4:initGun PORT MAP(
		CLK_INIT=>clk,
		EN_INIT=>SIG_FLG_INIT,
		RST_INIT=>SIG_FLG_PWR,
		RESUME_INIT=>SIG_FLG_RESUME,
		CMP_INIT=>SIG_CMP_INIT,
		STATE_INIT=>SIG_STATE_INIT
	);
	
	u5:mainGame PORT MAP(
		CLK_GAME=>clk,
		EN_GAME=>SIG_FLG_GAME,
		RST_GAME=>SIG_FLG_PWR,
		RESUME_GAME=>SIG_FLG_RESUME,
		BTN_SHOOT=>SIG_BTN_SHOOT,
		BTN_SPEED_DOWN=>SIG_BTN_SPEED_DOWN,
		BTN_SPEED_UP=>SIG_BTN_SPEED_UP,
		CMP_GAME=>SIG_CMP_GAME,
		STATE_GAME_TARGET=>SIG_STATE_GAME_TARGET,
		STATE_GAME_BULLET=>SIG_STATE_GAME_BULLET,
		STATE_GAME_TIME_LEFT=>SIG_STATE_GAME_TIME_LEFT,
		STATE_GAME_SCORE=>SIG_STATE_GAME_SCORE,
		STATE_GAME_SHOOT=>SIG_FLG_BULLET,
		FLG_BULLET_MISS=>SIG_FLG_BULLET_MISS,
		FLG_BULLET_GET=>SIG_FLG_BULLET_GET
	);
	
	u6:result PORT MAP(
		CLK_RESULT=>clk,
		EN_RESULT=>SIG_FLG_RESULT,
		STATE_GAME_TIME_LEFT=>SIG_STATE_GAME_TIME_LEFT,
		STATE_GAME_SCORE=>SIG_STATE_GAME_SCORE,
		FLG_WIN=>SIG_FLG_WIN,
		RESULT_TIME_LEFT=>SIG_RESULT_TIME_LEFT,
		RESULT_SCORE=>SIG_RESULT_SCORE
	);
	
	u7:displayer PORT MAP(
		CLK_DISP=>clk,
		FLG_PWR=>SIG_FLG_PWR,
		FLG_CHK=>SIG_FLG_CHK,
		FLG_WT=>SIG_FLG_WT,
		FLG_INIT=>SIG_FLG_INIT,
		FLG_GAME=>SIG_FLG_GAME,
		FLG_RESULT=>SIG_FLG_RESULT,
		FLG_WIN=>SIG_FLG_WIN,
		FLG_BULLET=>SIG_FLG_BULLET,
		STATE_CHK=>SIG_STATE_CHK,
		STATE_INIT=>SIG_STATE_INIT,
		STATE_GAME_TARGET=>SIG_STATE_GAME_TARGET,
		STATE_GAME_BULLET=>SIG_STATE_GAME_BULLET,
		STATE_GAME_TIME_LEFT=>SIG_STATE_GAME_TIME_LEFT,
		STATE_GAME_SCORE=>SIG_STATE_GAME_SCORE,
		RESULT_TIME_LEFT=>SIG_RESULT_TIME_LEFT,
		RESULT_SCORE=>SIG_RESULT_SCORE,
		LED0_OUT=>led0,
		CAT_OUT=>cat,
		DIGIT_OUT=>digit,
		ROW_OUT=>row,
		COLR_OUT=>colr,
		COLG_OUT=>colg
	);
	
	u8:buttonProcessor PORT MAP(
		CLK_BTNP=>clk,
		BTN0_IN=>btn0,
		BTN1_IN=>btn1,
		BTN6_IN=>btn6,
		BTN7_IN=>btn7,
		BTN_RESUME=>SIG_BTN_RESUME,
		BTN_SHOOT=>SIG_BTN_SHOOT,
		BTN_SPEED_DOWN=>SIG_BTN_SPEED_DOWN,
		BTN_SPEED_UP=>SIG_BTN_SPEED_UP
	);
	
	u9:musicPlayer PORT MAP(
		CLK_BEEP=>clk,
		FLG_PWR=>SIG_FLG_PWR,
		FLG_RESUME=>SIG_FLG_RESUME,
		FLG_CHK=>SIG_FLG_CHK,
		STATE_CHK=>SIG_STATE_CHK,
		STATE_CHK_SCAN=>SIG_STATE_CHK_SCAN,
		FLG_GAME=>SIG_FLG_GAME,
		FLG_BULLET_MISS=>SIG_FLG_BULLET_MISS,
		FLG_BULLET_GET=>SIG_FLG_BULLET_GET,
		FLG_RESULT=>SIG_FLG_RESULT,
		FLG_WIN=>SIG_FLG_WIN,
		TONE_OUT=>beep
	);
	
END gameDesign;