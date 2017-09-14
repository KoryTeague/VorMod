atkb_list = -1:15;
AC_list = 17:20;
atk_run = zeros(length(atkb_list), length(AC_list));
num_atks = 1000000;
for atkb = atkb_list
    atkb_ind = atkb - atkb_list(1) + 1;
    for AC = AC_list
        AC_ind = AC - AC_list(1) + 1;
        for atk = 1:num_atks
            roll = randi(20);
            % Hit
            if (roll + atkb >= AC && roll > 1) || roll == 20
                atk_run(atkb_ind, AC_ind) = atk_run(atkb_ind, AC_ind) + 1;
            end
        end
    end
end