function [m, n] = trigger_alignment(trigger, target)  
    m = zeros(1, length(trigger)); %non-target
    n = zeros(1, length(trigger)); %target
    k = 0;  
    j = 0;  
    
    for i = 2:length(trigger)
        if target(i) == 1 && target(i-1) == 0
            k = k + 1;
            n(k) = i;
        else 
            if trigger(i) ~= 0 && trigger(i-1) == 0 
                j = j + 1;
                m(j) = i;  
            end
        end
    end
    fprintf("find %d target pulse\n", k);
    fprintf("find %d non-target pulse\n", j);
    n = n(1:k);  
    m = m(1:j);  
end
