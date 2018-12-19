function [] = plotlevels( axes, fs, levels, sampleStep, length )

    stem(axes, levels, 'LineWidth', 1.5)
    hold(axes, 'on')
    plot(axes, levels, 'LineWidth', 1.5)
    title(axes, 'Logger', 'Fontsize', 13)
    ylim(axes, [0 120])
    xlabel(axes, 'Time (s)', 'Fontsize', 13)
    ylabel(axes, 'dBSPL', 'Fontsize', 13)
    hold(axes, 'off')
    
    ticks = get(axes, 'XTick');
    
    labels = round(ticks*sampleStep/fs, 2);

    set(axes, 'XTickLabel', labels);
    
end

