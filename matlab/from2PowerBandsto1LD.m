function from2PowerBandsto1LD(powerBands)

    %% From POWER bands to LD Power Output with 1 LD
    % powerBands: matrix with time domain power signal, each column one power band 
    % here an example code
    FeaturePower1 = powerBands(:,1);
    FeaturePower2 = powerBands(:,2);
    featureLength = 2;

    FractionalFixedPointValue = 8;  % 0 default value; should be 1, 2, 4, or 8 (Dave's suggestsion is to use 8) if we want to use weighting with two or more power bands
    WeightVector = [1 1 0 0];   % here we indicate the power band/s we using
    NormalizationMultiplyVector = [1 1 0 0];    % 0 default; should be 1 or different than 0 if we want to scale/normalize several features in 1 LDPowerOutput
    NormalizationSubtractVector = [x y 0 0];    % 0 default; this x, y, values are the variables we are looking for to substract artifact from physiological power

    for i = 1 : featureLength
        for j = 1 : length(FeaturePower1) 
            W(i) = (WeightVector(i)) / 2^FractionalFixedPointValue;
            M(i) 	= (NormalizationMultiplyVector(i)) / 2^FractionalFixedPointValue;
            ScaledFeaturePower(j,i) = W(i) * M(i) * (FeaturePower(j,i)-NormalizationSubtractVector(i));
        end
    end

    LDPowerOutput = sum (ScaledFeaturePower);

end