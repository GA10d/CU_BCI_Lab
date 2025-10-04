function y = trigger_alignment(x,target)
    y = zeros(1, length(x)); 
    k = 0; 
    
    for i = 1:length(x)
        if x(i) == target 
            k = k + 1;
            y(k) = i;
        end
    end
    fprintf("find %d pulse\n", k);
    y = y(1:k);  
end
