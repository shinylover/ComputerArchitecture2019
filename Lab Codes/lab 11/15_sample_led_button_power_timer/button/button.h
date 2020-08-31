
extern int i, n, j, counter;
extern int interrupt; 							//indicate cuuent intrupt is even or ood
extern int arr_source[];							//used to store the random light sequence




void BUTTON_init(void);

void EINT1_IRQHandler(void);
void EINT2_IRQHandler(void);
void EINT3_IRQHandler(void);

void Check(int temp);
void Simon_LED_On_Off(void);
