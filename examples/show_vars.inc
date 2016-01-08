# Shows all defined expect-lite Vars
; === Show all Vars Defined
# !set var_list [array names user_namespace]
# !set var_list_sorted [lsort $var_list]
# !foreach i $var_list_sorted {
# !       puts "Var:$i \t\t\Value:$user_namespace($i)"
# !}
>
*SHOW VARS
>sleep 1
>
>echo "bye"
>
