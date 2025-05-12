; ModuleID = 'my_src/using_va.c'
source_filename = "my_src/using_va.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.__va_list_tag = type { i32, i32, ptr, ptr }

@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @my_func(ptr noundef %file, ptr noundef %v) #0 {
entry:
  %file.addr = alloca ptr, align 8
  %v.addr = alloca ptr, align 8
  %i = alloca i32, align 4
  store ptr %file, ptr %file.addr, align 8
  store ptr %v, ptr %v.addr, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, ptr %i, align 4
  %cmp = icmp slt i32 %0, 10
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load ptr, ptr %file.addr, align 8
  %2 = load ptr, ptr %v.addr, align 8
  %gp_offset_p = getelementptr inbounds nuw %struct.__va_list_tag, ptr %2, i32 0, i32 0
  %gp_offset = load i32, ptr %gp_offset_p, align 8
  %fits_in_gp = icmp ule i32 %gp_offset, 40
  br i1 %fits_in_gp, label %vaarg.in_reg, label %vaarg.in_mem ;If within 6 registers used for passing arguments (offset is at most 40), use in_arg. Else, in_mem.

vaarg.in_reg:                                     ; preds = %for.body
  %3 = getelementptr inbounds nuw %struct.__va_list_tag, ptr %2, i32 0, i32 3
  %reg_save_area = load ptr, ptr %3, align 8
  %4 = getelementptr i8, ptr %reg_save_area, i32 %gp_offset
  %5 = add i32 %gp_offset, 8
  store i32 %5, ptr %gp_offset_p, align 8
  br label %vaarg.end

vaarg.in_mem:                                     ; preds = %for.body
  %overflow_arg_area_p = getelementptr inbounds nuw %struct.__va_list_tag, ptr %2, i32 0, i32 2
  %overflow_arg_area = load ptr, ptr %overflow_arg_area_p, align 8
  %overflow_arg_area.next = getelementptr i8, ptr %overflow_arg_area, i32 8
  store ptr %overflow_arg_area.next, ptr %overflow_arg_area_p, align 8
  br label %vaarg.end

vaarg.end:                                        ; preds = %vaarg.in_mem, %vaarg.in_reg
  %vaarg.addr = phi ptr [ %4, %vaarg.in_reg ], [ %overflow_arg_area, %vaarg.in_mem ]
  %6 = load i32, ptr %vaarg.addr, align 4
  %call = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %1, ptr noundef @.str, i32 noundef %6) #2
  br label %for.inc

for.inc:                                          ; preds = %vaarg.end
  %7 = load i32, ptr %i, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, ptr %i, align 4
  br label %for.cond, !llvm.loop !6

for.end:                                          ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind
declare i32 @fprintf(ptr noundef, ptr noundef, ...) #1

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 21.0.0git (https://github.com/llvm/llvm-project.git 1ff2953f5e393eb8634ea3c4ccc85221e76dfcb9)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
