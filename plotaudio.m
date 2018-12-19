function [ ] = plotaudio( axes, audio, fs, name )


    t = (0: 1/fs : length(audio)/fs - 1/fs);
    plot(axes, t, audio);
    title(axes, sprintf('%s', name), 'Interpreter', 'none', 'Fontsize', 13)
    xlabel(axes, 'Time (s)', 'Fontsize', 13)
    ylabel(axes, 'Amplitude', 'Fontsize', 13)


end

