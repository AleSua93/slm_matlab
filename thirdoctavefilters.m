function [ thirdOctaveFilterBank, centralFrequencies ] = thirdoctavefilters()
    % Esta funcion devuelve un banco de filtros de tercio de octava
    % segun norma ANSI S1.11-2004

    %Diseñamos un filtro de banda de tercio de octava

    bandsPerOctave = 3;
    filterOrder = 6;
    centralF = 1000;
    fs = 48000;
    thirdOctaveFilter = fdesign.octave(bandsPerOctave, 'Class 0', 'N,F0', ...
        filterOrder, centralF, fs);

    % Obtenemos las frecuencias centrales en el rango audible

    centralFrequencies = validfrequencies(thirdOctaveFilter);
    numCentralFrequencies = length(centralFrequencies);

    for i=1:numCentralFrequencies,
        thirdOctaveFilter.F0 = centralFrequencies(i);
        thirdOctaveFilterBank(i) = design(thirdOctaveFilter,'butter');
    end

    % Visualizamos los filtros

    %fvtool(thirdOctaveFilterBank(17),'FrequencyScale','log','Color','white');
    %axis([0.1 24 -90 5])
    %title('1/3 octave filter')

end

