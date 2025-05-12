#include <stdarg.h>
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>

int my_va_arg(va_list v){
    uint32_t gp_offset = v->gp_offset;
    int ret = 0;
    if (gp_offset>40){
        int *of_area = v->overflow_arg_area;
        ret = *of_area;
        v->overflow_arg_area += 8;
    }
    else{
        char *reg_area = v->reg_save_area;
        int *reg_ptr = (int *)(reg_area+gp_offset);
        v->gp_offset+=8;
        ret =  *reg_ptr;
    }
    return ret;
}

void my_func(FILE *file, va_list v){
    for(int i = 0;i < 10;i ++){
        fprintf(file, "%d\n",my_va_arg(v));
    }   
}

void test_my_func(FILE *file, ...){
    va_list my_list;
    va_start(my_list,file);
    my_func(file,my_list);
}

int main(){
    test_my_func(stdout,1,2,3,4,5,6,7,8,9,10);
}