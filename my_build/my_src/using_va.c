#include <stdarg.h>
#include <stdio.h>

void my_func(FILE *file, va_list v){
    for(int i = 0;i < 10;i ++){
        fprintf(file, "%d\n",va_arg(v,int));
    }   
}