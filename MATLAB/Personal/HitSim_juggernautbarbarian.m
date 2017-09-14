AC_list = 9:30;
dmg_run = zeros(length(AC_list), 12);    % total dmg at AC over num_rounds
atk_run = zeros(length(AC_list), 12);    % total hits at AC over num_rounds
crit_run = zeros(length(AC_list), 12);   % total crits at AC over num_rounds
num_rounds = 10000;
% All level 20
for AC = AC_list
    ind = AC - AC_list(1) + 1;
    %% Fighter; 20 Str, TWF FS, EA 4, SS, Champion
    % 5, +11 atk, 1d6+5 dmg MWAs; 18-20 crit range
    for round = 1:num_rounds
        % Attack Action w/BA TWF Attack
        for atk = 1:5
            roll = randi(20);
            % Hit
            if roll >= AC - 11 && roll > 1
                dmg_run(ind, 1) = dmg_run(ind, 1) + randi(6) + 5;
                atk_run(ind, 1) = atk_run(ind, 1) + 1;
            end
            % Crit
            if roll >= 18
                dmg_run(ind, 1) = dmg_run(ind, 1) + randi(6);
                crit_run(ind, 1) = crit_run(ind, 1) + 1;
            end
        end
    end
    %% Fighter; 20 Str, TWF FS, EA 4, SS, Champion, Action Surge
    % 9, +11 atk, 1d6+5 dmg MWAs; 18-20 crit range
    for round = 1:num_rounds
        % Attack Action w/BA TWF Attack
        for atk = 1:9
            roll = randi(20);
            % Hit
            if roll >= AC - 11 && roll > 1
                dmg_run(ind, 2) = dmg_run(ind, 2) + randi(6) + 5;
                atk_run(ind, 2) = atk_run(ind, 2) + 1;
            end
            % Crit
            if roll >= 18
                dmg_run(ind, 2) = dmg_run(ind, 2) + randi(6);
                crit_run(ind, 2) = crit_run(ind, 2) + 1;
            end
        end
    end
    %% Fighter; 20 Str, TWF FS, EA 4, Rapiers (DW Feat), Champion
    % 5 +11 atk, 1d8+5 dmg MWAs; 18-20 crit range
    for round = 1:num_rounds
        % Attack Action w/BA TWF Attack
        for atk = 1:5
            roll = randi(20);
            % Hit
            if roll >= AC - 11 && roll > 1
                dmg_run(ind, 3) = dmg_run(ind, 3) + randi(8) + 5;
                atk_run(ind, 3) = atk_run(ind, 3) + 1;
            end
            % Crit
            if roll >= 18
                dmg_run(ind, 3) = dmg_run(ind, 3) + randi(8);
                crit_run(ind, 3) = crit_run(ind, 3) + 1;
            end
        end
    end
    %% Fighter; 20 Str, TWF FS, EA 4, Rapiers (DW Feat), Champion, Action Surge
    % 9, +11 atk, 1d8+5 dmg MWAs; 18-20 crit range
    for round = 1:num_rounds
        % Attack Action w/BA TWF Attack
        for atk = 1:9
            roll = randi(20);
            % Hit
            if roll >= AC - 11 && roll > 1
                dmg_run(ind, 4) = dmg_run(ind, 4) + randi(8) + 5;
                atk_run(ind, 4) = atk_run(ind, 4) + 1;
            end
            % Crit
            if roll >= 18
                dmg_run(ind, 4) = dmg_run(ind, 4) + randi(8);
                crit_run(ind, 4) = crit_run(ind, 4) + 1;
            end
        end
    end
    %% Barbarian; 24 Str, Brutal Crit, EA 2, LS, Juggernaut
    % 2, +13 1d8+7 dmg MWAs; 1, +13 1d8+3 dmg MWA; +3 crit dice
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:2
            roll = randi(20);
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 5) = dmg_run(ind, 5) + randi(8) + 7;
                atk_run(ind, 5) = atk_run(ind, 5) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 5) = dmg_run(ind, 5) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 5) = crit_run(ind, 5) + 1;
            end
        end
        % BA TWF Attack
        for atk = 1:1
            roll = randi(20);
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 5) = dmg_run(ind, 5) + randi(8) + 3;
                atk_run(ind, 5) = atk_run(ind, 5) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 5) = dmg_run(ind, 5) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 5) = crit_run(ind, 5) + 1;
            end
        end
    end
    %% Barbarian; 24 Str, Rage, Brutal Crit, 2, LS, Juggernaut
    % 2, +13 1d8+11 dmg MWAs; 1, +13 1d8+7 dmg MWA; +3 crit dice
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:2
            roll = randi(20);
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 6) = dmg_run(ind, 6) + randi(8) + 11;
                atk_run(ind, 6) = atk_run(ind, 6) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 6) = dmg_run(ind, 6) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 6) = crit_run(ind, 6) + 1;
            end
        end
        % BA TWF Attack
        for atk = 1:1
            roll = randi(20);
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 6) = dmg_run(ind, 6) + randi(8) + 7;
                atk_run(ind, 6) = atk_run(ind, 6) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 6) = dmg_run(ind, 6) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 6) = crit_run(ind, 6) + 1;
            end
        end
    end
    %% Barbarian; 24 Str, Reckless Attack, Brutal Crit, 2, LS, Juggernaut
    % 2, +13 1d8+7 dmg MWAs, 1, +13 1d8+3 dmg MWA; +3 crit dice, adv
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:2
            roll = max(randi(20), randi(20));
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 7) = dmg_run(ind, 7) + randi(8) + 7;
                atk_run(ind, 7) = atk_run(ind, 7) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 7) = dmg_run(ind, 7) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 7) = crit_run(ind, 7) + 1;
            end
        end
        % BA TWF Attack
        for atk = 1:1
            roll = max(randi(20), randi(20));
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 7) = dmg_run(ind, 7) + randi(8) + 3;
                atk_run(ind, 7) = atk_run(ind, 7) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 7) = dmg_run(ind, 7) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 7) = crit_run(ind, 7) + 1;
            end
        end
    end
    %% Barbarian; 24 Str, Rage, Reckless Attack, Brutal Crit, 2, LS, Juggernaut
    % 2, +13 1d8+11 dmg MWAs, 1, +13 1d8+7 dmg MWA; +3 crit dice, adv
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:2
            roll = max(randi(20), randi(20));
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 8) = dmg_run(ind, 8) + randi(8) + 11;
                atk_run(ind, 8) = atk_run(ind, 8) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 8) = dmg_run(ind, 8) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 8) = crit_run(ind, 8) + 1;
            end
        end
        % BA TWF Attack
        for atk = 1:1
            roll = max(randi(20), randi(20));
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 8) = dmg_run(ind, 8) + randi(8) + 7;
                atk_run(ind, 8) = atk_run(ind, 8) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 8) = dmg_run(ind, 8) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 8) = crit_run(ind, 8) + 1;
            end
        end
    end
    %% Barbarian; 24 Str, Brutal Crit, EA 2, LS, Juggernaut (alt)
    % 2, +13 1d8+7 dmg MWAs; 1, +13 1d8 dmg MWA; +3 crit dice
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:2
            roll = randi(20);
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 9) = dmg_run(ind, 9) + randi(8) + 7;
                atk_run(ind, 9) = atk_run(ind, 9) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 9) = dmg_run(ind, 9) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 9) = crit_run(ind, 9) + 1;
            end
        end
        % BA TWF Attack
        for atk = 1:1
            roll = randi(20);
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 9) = dmg_run(ind, 9) + randi(8);
                atk_run(ind, 9) = atk_run(ind, 9) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 9) = dmg_run(ind, 9) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 9) = crit_run(ind, 9) + 1;
            end
        end
    end
    %% Barbarian; 24 Str, Rage, Brutal Crit, 2, LS, Juggernaut (alt)
    % 2, +13 1d8+11 dmg MWAs; 1, +13 1d8+4 dmg MWA; +3 crit dice
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:2
            roll = randi(20);
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 10) = dmg_run(ind, 10) + randi(8) + 11;
                atk_run(ind, 10) = atk_run(ind, 10) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 10) = dmg_run(ind, 10) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 10) = crit_run(ind, 10) + 1;
            end
        end
        % BA TWF Attack
        for atk = 1:1
            roll = randi(20);
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 10) = dmg_run(ind, 10) + randi(8) + 4;
                atk_run(ind, 10) = atk_run(ind, 10) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 10) = dmg_run(ind, 10) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 10) = crit_run(ind, 10) + 1;
            end
        end
    end
    %% Barbarian; 24 Str, Reckless Attack, Brutal Crit, 2, LS, Juggernaut (alt)
    % 2, +13 1d8+7 dmg MWAs, 1, +13 1d8 dmg MWA; +3 crit dice, adv
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:2
            roll = max(randi(20), randi(20));
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 11) = dmg_run(ind, 11) + randi(8) + 7;
                atk_run(ind, 11) = atk_run(ind, 11) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 11) = dmg_run(ind, 11) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 11) = crit_run(ind, 11) + 1;
            end
        end
        % BA TWF Attack
        for atk = 1:1
            roll = max(randi(20), randi(20));
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 11) = dmg_run(ind, 11) + randi(8);
                atk_run(ind, 11) = atk_run(ind, 11) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 11) = dmg_run(ind, 11) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 11) = crit_run(ind, 11) + 1;
            end
        end
    end
    %% Barbarian; 24 Str, Rage, Reckless Attack, Brutal Crit, 2, LS, Juggernaut
    % 2, +13 1d8+11 dmg MWAs, 1, +13 1d8+4 dmg MWA; +3 crit dice, adv
    for round = 1:num_rounds
        % Attack Action
        for atk = 1:2
            roll = max(randi(20), randi(20));
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 12) = dmg_run(ind, 12) + randi(8) + 11;
                atk_run(ind, 12) = atk_run(ind, 12) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 12) = dmg_run(ind, 12) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 12) = crit_run(ind, 12) + 1;
            end
        end
        % BA TWF Attack
        for atk = 1:1
            roll = max(randi(20), randi(20));
            % Hit
            if roll >= AC - 13 && roll > 1
                dmg_run(ind, 12) = dmg_run(ind, 12) + randi(8) + 4;
                atk_run(ind, 12) = atk_run(ind, 12) + 1;
            end
            % Crit
            if roll >= 20
                dmg_run(ind, 12) = dmg_run(ind, 12) + randi(8) + randi(8) + randi(8) + randi(8);
                crit_run(ind, 12) = crit_run(ind, 12) + 1;
            end
        end
    end
end