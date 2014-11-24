/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "E:/Programmation/Projet S5/Motor_controller/pwm_generator.vhd";
extern char *IEEE_P_2592010699;
extern char *IEEE_P_3499444699;

unsigned char ieee_p_2592010699_sub_1744673427_503743352(char *, char *, unsigned int , unsigned int );
char *ieee_p_3499444699_sub_1438093509_3536714472(char *, char *, char *, char *, int );
unsigned char ieee_p_3499444699_sub_2368615388_3536714472(char *, char *, char *, int );
unsigned char ieee_p_3499444699_sub_2591093089_3536714472(char *, char *, char *, char *, char *);


static void work_a_1391599013_3212880686_p_0(char *t0)
{
    char t11[16];
    char *t1;
    char *t2;
    unsigned char t3;
    unsigned char t4;
    char *t5;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    unsigned int t12;
    unsigned int t13;
    char *t14;
    char *t15;
    char *t16;

LAB0:    xsi_set_current_line(47, ng0);
    t1 = (t0 + 1192U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)3);
    if (t4 != 0)
        goto LAB2;

LAB4:    t1 = (t0 + 992U);
    t3 = ieee_p_2592010699_sub_1744673427_503743352(IEEE_P_2592010699, t1, 0U, 0U);
    if (t3 != 0)
        goto LAB5;

LAB6:
LAB3:    t1 = (t0 + 3712);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(48, ng0);
    t1 = xsi_get_transient_memory(2U);
    memset(t1, 0, 2U);
    t5 = t1;
    memset(t5, (unsigned char)2, 2U);
    t6 = (t0 + 3792);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    t9 = (t8 + 56U);
    t10 = *((char **)t9);
    memcpy(t10, t1, 2U);
    xsi_driver_first_trans_fast(t6);
    xsi_set_current_line(49, ng0);
    t1 = xsi_get_transient_memory(2U);
    memset(t1, 0, 2U);
    t2 = t1;
    memset(t2, (unsigned char)2, 2U);
    t5 = (t0 + 3856);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 2U);
    xsi_driver_first_trans_fast(t5);
    xsi_set_current_line(50, ng0);
    t1 = xsi_get_transient_memory(100U);
    memset(t1, 0, 100U);
    t2 = t1;
    memset(t2, (unsigned char)2, 100U);
    t5 = (t0 + 3920);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 100U);
    xsi_driver_first_trans_fast(t5);
    xsi_set_current_line(51, ng0);
    t1 = (t0 + 3984);
    t2 = (t1 + 56U);
    t5 = *((char **)t2);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((unsigned char *)t7) = (unsigned char)2;
    xsi_driver_first_trans_fast_port(t1);
    goto LAB3;

LAB5:    xsi_set_current_line(53, ng0);
    t2 = (t0 + 1672U);
    t5 = *((char **)t2);
    t2 = (t0 + 6172U);
    t6 = ieee_p_3499444699_sub_1438093509_3536714472(IEEE_P_3499444699, t11, t5, t2, 1);
    t7 = (t11 + 12U);
    t12 = *((unsigned int *)t7);
    t13 = (1U * t12);
    t4 = (100U != t13);
    if (t4 == 1)
        goto LAB7;

LAB8:    t8 = (t0 + 3920);
    t9 = (t8 + 56U);
    t10 = *((char **)t9);
    t14 = (t10 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t6, 100U);
    xsi_driver_first_trans_fast(t8);
    xsi_set_current_line(54, ng0);
    t1 = (t0 + 1352U);
    t2 = *((char **)t1);
    t1 = (t0 + 3792);
    t5 = (t1 + 56U);
    t6 = *((char **)t5);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    memcpy(t8, t2, 2U);
    xsi_driver_first_trans_fast(t1);
    xsi_set_current_line(55, ng0);
    t1 = (t0 + 1672U);
    t2 = *((char **)t1);
    t1 = (t0 + 6172U);
    t3 = ieee_p_3499444699_sub_2368615388_3536714472(IEEE_P_3499444699, t2, t1, 0);
    if (t3 != 0)
        goto LAB9;

LAB11:
LAB10:    goto LAB3;

LAB7:    xsi_size_not_matching(100U, t13, 0);
    goto LAB8;

LAB9:    xsi_set_current_line(56, ng0);
    t5 = (t0 + 1832U);
    t6 = *((char **)t5);
    t5 = (t0 + 6188U);
    t7 = ieee_p_3499444699_sub_1438093509_3536714472(IEEE_P_3499444699, t11, t6, t5, 1);
    t8 = (t11 + 12U);
    t12 = *((unsigned int *)t8);
    t13 = (1U * t12);
    t4 = (2U != t13);
    if (t4 == 1)
        goto LAB12;

LAB13:    t9 = (t0 + 3856);
    t10 = (t9 + 56U);
    t14 = *((char **)t10);
    t15 = (t14 + 56U);
    t16 = *((char **)t15);
    memcpy(t16, t7, 2U);
    xsi_driver_first_trans_fast(t9);
    xsi_set_current_line(57, ng0);
    t1 = (t0 + 1832U);
    t2 = *((char **)t1);
    t1 = (t0 + 6188U);
    t5 = (t0 + 1992U);
    t6 = *((char **)t5);
    t5 = (t0 + 6204U);
    t3 = ieee_p_3499444699_sub_2591093089_3536714472(IEEE_P_3499444699, t2, t1, t6, t5);
    if (t3 != 0)
        goto LAB14;

LAB16:    xsi_set_current_line(60, ng0);
    t1 = (t0 + 3984);
    t2 = (t1 + 56U);
    t5 = *((char **)t2);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((unsigned char *)t7) = (unsigned char)2;
    xsi_driver_first_trans_fast_port(t1);

LAB15:    goto LAB10;

LAB12:    xsi_size_not_matching(2U, t13, 0);
    goto LAB13;

LAB14:    xsi_set_current_line(58, ng0);
    t7 = (t0 + 3984);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    t10 = (t9 + 56U);
    t14 = *((char **)t10);
    *((unsigned char *)t14) = (unsigned char)3;
    xsi_driver_first_trans_fast_port(t7);
    goto LAB15;

}


extern void work_a_1391599013_3212880686_init()
{
	static char *pe[] = {(void *)work_a_1391599013_3212880686_p_0};
	xsi_register_didat("work_a_1391599013_3212880686", "isim/pwm_generator_isim_beh.exe.sim/work/a_1391599013_3212880686.didat");
	xsi_register_executes(pe);
}
