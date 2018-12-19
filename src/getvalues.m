function [ splValues, leqs, globalLeq, samplesStep ] = ...
    getvalues( audio, audioCal, fs, intTime, filterBank, weighting )

    % Definimos las ponderaciones

    wA = [-44.7 -39.4  -34.6 -30.2 -26.2 -22.5 -19.1 -16.1 -13.4 -10.9 ...
            -8.6 -6.6 -4.8 -3.2 -1.9 -0.8 0 0.6 1 1.2 1.3 1.2 1 0.5 ...
            -0.1 -1.1 -2.5 -4.3 -6.6 -9.3];
        
    wArms = 10.^(wA/10);
        
    wC = [-4.4 -3.0 -2.0 -1.3 -0.8 -0.5 -0.3 -0.2 -0.1 0 0 0 0 0 0 0 0 0 ...
        -0.1 -0.2 -0.3 -0.5 -0.8 -1.3 -2.0 -3.0 -4.4 -6.2 -8.5 -11.2];
    
    wCrms = 10.^(wC/10);

    % Definimos presión de referencia
    
    referencePressure = 20 * 10^(-6);

    % Calibramos
    
    audio = audio/rms(audioCal);
    
    % Definimos el paso de muestras y la cantidad de iteraciones del loop
    
    samplesStep = round(intTime*fs);
    
    iterations = floor(length(audio) / samplesStep);
    
    rmsValues = zeros(iterations, length(filterBank));
    leqs = zeros(1, length(filterBank));
    
    % First, we calculate values per band
    
    for k = 1:length(filterBank)
        
        audioFilt = filter(filterBank(k), audio);
    
        for i = 1:iterations

            rmsValue = rms(audioFilt(1:samplesStep));
            
            % Ponderamos
            
            if weighting == 'A'
                rmsValues(i, k) = (rmsValue^2) * wArms(k);
            elseif weighting == 'C'
                rmsValues(i, k) = (rmsValue^2) * wCrms(k);
            else
                rmsValues(i, k) = (rmsValue^2);
            end
                
            audioFilt = audioFilt(samplesStep: length(audioFilt));

        end
    
    end
    
    splValues = 10*log10(rmsValues./referencePressure^2);
    
    % Calculamos leqs
    
    totalEnergySum = 0;
    
    for k = 1:length(filterBank)
        
        energySum = 0;
    
        for i = 1:iterations

            energySum = energySum + rmsValues(i, k);

        end
        
        leqs(1, k) = 10*log10(energySum/(i*referencePressure^2));
        
        totalEnergySum = totalEnergySum + energySum;
    
    end
    
    globalLeq = 10*log10(totalEnergySum/(i*referencePressure^2));
    
    % Calculamos globales en tiempo
    
    globalValues = zeros(iterations, 1);
    
    for k = 1:length(filterBank)
        
        globalValues(:, 1) = globalValues + 10.^(splValues(:, k)/10);
        
    end
    
    globalValues = 10*log10(globalValues);
    
    % Concatenamos los valores globales a los valores por banda
    % De forma que index 31 nos da globales
    
    splValues = horzcat(splValues, globalValues);
    
    splValues(splValues < 0) = 0;
    leqs(leqs < 0) = 0;
    globalLeq(globalLeq < 0) = 0;  
    
end

