AC_list = 9:30;
dmg_run = zeros(length(AC_list), 6);    % total dmg at AC over num_rounds
atk_run = zeros(length(AC_list), 6);    % total hits at AC over num_rounds
crit_run = zeros(length(AC_list), 6);   % total crits at AC over num_rounds
num_rounds = 10000;
% All level 20
for AC = AC_list
    ind = AC - AC_list(1) + 1;
    %% Path of Ruin Barbarian; 24 Str, 24 Con, 18 Dex; Rage, Brutal Crit, 2 EA, BA, Harbinger of Death, Expanded Crit
    % 2, +13 2d6+11 Sla +7 Nec dmg MWAs; +3 crit dice, 19-20 Crit Range
    play = 1;
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:2
            roll = randi(20);
            % Hit
            if (roll >= AC - 13 && roll > 1) || roll >= 19
                dmg_run(ind, play) = dmg_run(ind, play) + randi(12) + 18;
                atk_run(ind, play) = atk_run(ind, play) + 1;
            end
            % Crit
            if roll >= 19
                dmg_run(ind, play) = dmg_run(ind, play) + randi(12) + randi(12) + randi(12) + randi(12);
                crit_run(ind, play) = crit_run(ind, play) + 1;
            end
        end
    end
    %% Path of Ruin Barbarian; 24 Str, 24 Con, 18 Dex; Rage, Brutal Crit, 2 EA, GS, Harbinger of Death, Expanded Crit
    % 2, +13 2d6+11 Sla +7 Nec dmg MWAs; +3 crit dice, 19-20 Crit Range
    play = 2;
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:2
            roll = randi(20);
            % Hit
            if (roll >= AC - 13 && roll > 1) || roll >= 19
                dmg_run(ind, play) = dmg_run(ind, play) + randi(6) + randi(6) + 18;
                atk_run(ind, play) = atk_run(ind, play) + 1;
            end
            % Crit
            if roll >= 19
                dmg_run(ind, play) = dmg_run(ind, play) + randi(6) + randi(6) + randi(6) + randi(6);
                crit_run(ind, play) = crit_run(ind, play) + 1;
            end
        end
    end
    %% Champion Fighter; 20 Str, GWF, 4 EA, Superior Critical, GS
    % 4, +11 2d6+5 Sla MWAs; 18-20 Crit Range
    play = 3;
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:4
            roll = randi(20);
            % Hit
            if (roll >= AC - 11 && roll > 1) || roll >= 18
                dmg1 = randi(6);
                if dmg1 <= 2
                    dmg1 = randi(6);
                end
                dmg2 = randi(6);
                if dmg2 <= 2
                    dmg2 = randi(6);
                end
                dmg_run(ind, play) = dmg_run(ind, play) + dmg1 + dmg2 + 5;
                atk_run(ind, play) = atk_run(ind, play) + 1;
            end
            % Crit
            if roll >= 18
                dmg = randi(6);
                if dmg <= 2;
                    dmg = randi(6);
                end
                dmg_run(ind, play) = dmg_run(ind, play) + dmg;
                crit_run(ind, play) = crit_run(ind, play) + 1;
            end
        end
    end
    %% Champion Fighter; 20 Str, GWF, 4 EA, Superior Critical, GA
    % 4, +11 1d12+5 Sla MWAs; 18-20 Crit Range
    play = 4;
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:4
            roll = randi(20);
            % Hit
            if (roll >= AC - 11 && roll > 1) || roll >= 18
                dmg = randi(12);
                if dmg <= 2
                    dmg = randi(12);
                end
                dmg_run(ind, play) = dmg_run(ind, play) + dmg + 5;
                atk_run(ind, play) = atk_run(ind, play) + 1;
            end
            % Crit
            if roll >= 18
                dmg = randi(12);
                if dmg <= 2;
                    dmg = randi(12);
                end
                dmg_run(ind, play) = dmg_run(ind, play) + dmg;
                crit_run(ind, play) = crit_run(ind, play) + 1;
            end
        end
    end
    %% Path of Ruin Barbarian; 24 Str, 24 Con, 18 Dex; Rage, Brutal Crit, 2 EA, GS, Harbinger of Death, Expanded Crit, Reckless Attack
    % 2, +13 2d6+11 Sla +7 Nec dmg MWAs; +3 crit dice, 19-20 Crit Range
    play = 5;
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:2
            roll = max(randi(20), randi(20));
            % Hit
            if (roll >= AC - 13 && roll > 1) || roll >= 19
                dmg_run(ind, play) = dmg_run(ind, play) + randi(6) + randi(6) + 18;
                atk_run(ind, play) = atk_run(ind, play) + 1;
            end
            % Crit
            if roll >= 19
                dmg_run(ind, play) = dmg_run(ind, play) + randi(6) + randi(6) + randi(6) + randi(6);
                crit_run(ind, play) = crit_run(ind, play) + 1;
            end
        end
    end
    %% Path of Ruin Barbarian; 24 Str, 24 Con, 18 Dex; Rage, Brutal Crit, 2 EA, GA, Harbinger of Death, Expanded Crit, Reckless Attack
    % 2, +13 1d12+11 Sla +7 Nec dmg MWAs; +3 crit dice, 19-20 Crit Range
    play = 6;
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:2
            roll = max(randi(20), randi(20));
            % Hit
            if (roll >= AC - 13 && roll > 1) || roll >= 19
                dmg_run(ind, play) = dmg_run(ind, play) + randi(12) + 18;
                atk_run(ind, play) = atk_run(ind, play) + 1;
            end
            % Crit
            if roll >= 19
                dmg_run(ind, play) = dmg_run(ind, play) + randi(12) + randi(12) + randi(12) + randi(12);
                crit_run(ind, play) = crit_run(ind, play) + 1;
            end
        end
    end
end