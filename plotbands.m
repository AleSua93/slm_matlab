function [] = plotbands( axes, leqs, centralFrequencies, selectedIndex )
    
    bar(axes, log10(centralFrequencies), leqs);
    hold(axes, 'on')
    if (selectedIndex < 31)
        leqs(leqs ~= ...
            leqs(selectedIndex)) = 0;
        bar(axes, log10(centralFrequencies), leqs, 'r')
    end
    hold(axes, 'off')
    title(axes, 'Leq values per band', 'Fontsize', 13)
    xlabel(axes, 'Central frequency (Hz)', 'Fontsize', 13)
    ylabel(axes, 'dBSPL', 'Fontsize', 13)
    xlim(axes, [1.3 4.38])
    ylim(axes, [0 120])
    ticks = get(axes,'XTick');
    ticks = 10.^ticks;
    set(axes, 'XTickLabel', round(ticks));


end

