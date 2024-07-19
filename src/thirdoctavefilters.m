function [ thirdOctaveFilterBank, centralFrequencies ] = thirdoctavefilters( varargin )
    % This function returns a bank of third octave filters according to 
    % ANSI S1.11-2004

    % Local Options
    
    locOpts = struct( "optin",   {"bands|bandsPerOctabe" , "filterOrder|order", "centralF|fc" , "fs"       }, ...
                      "varname", {"bandsPerOctabe"       ,  "filterOrder"     , "centralF"    , "fs"       }, ...
                     "checks",   { @(x) x > 1            ,  @(x) x > 1        , @(x) x > 0    , @(x) x > 0 } );

   
    % Default Settings
    bandsPerOctave = 3;
    filterOrder = 6;
    centralF = 1000;
    fs = 48000;

    % Check if any field is present
    vkindex = [];
    for idx=1:length(locOpts)
        varList = split( locOpts(idx).optin, "|" );
        for ivar = 1:length( varList )
            var = varList(ivar);
            loc =  find( cellfun(@(v) ( isstring(v) || ischar(v) ) && strcmpi( var, v ), varargin ) );
            if isempty(loc) || ismember(loc, vkindex) 
                continue;
            elseif (loc > nargin-1) 
                error( "NOT ENOUGHT INPUT ARGUMENTS!" );
            else
                if isempty( locOpts(idx).checks ) || feval( locOpts(idx).checks, varargin{loc+1} )
                    eval( sprintf( "%s = varargin{loc+1};", locOpts(idx).varname ) );
                else 
                    error( sprintf( "Value for option '%s' not valid!", var ) );
                end
                vkindex = [vkindex loc loc+1];
                break;
            end
        end
    end

    % Third octave band filter design

    thirdOctaveFilter = fdesign.octave(bandsPerOctave, 'Class 0', 'N,F0', ...
        filterOrder, centralF, fs);

    % Central Frequencies calculations

    centralFrequencies = validfrequencies(thirdOctaveFilter);
    numCentralFrequencies = length(centralFrequencies);

    for i=1:numCentralFrequencies
        thirdOctaveFilter.F0 = centralFrequencies(i);
        thirdOctaveFilterBank(i) = design(thirdOctaveFilter,'butter');
    end

end

