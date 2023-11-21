%% Global Threshold
% Fun��o que transforma uma imagem GEOTIFF em bin�ria utilizando apenas um Threshold

% Recebe a Imagem e o respetivo threshold
% Retorna a Imagem binarizada e um array com o valor dos pixeis detetados

function [binaryIMG,boatPixelValue] = Binary_TH(Image, thresholdFactor)

%Sele��o da polariza��o, existem duas hipoteses pois em algumas das imagens
%apenas temos acesso a polariza��o que � VV
dim = size(Image);
if(length(dim) > 2)
    img(:,:,1) = Image(:,:,2);
    img(:,:,2) = Image(:,:,2); %Polariza��o VV
    img(:,:,3) = Image(:,:,2);
else
    img(:,:,1) = Image;
    img(:,:,2) = Image; %Polariza��o VV
    img(:,:,3) = Image;
end

[rows, cols] = size(img(:,:,1));

% Inicializa��o da matrix de tresholds
threshold = zeros(rows, cols);



Imax =max(max(img(:,:,1)));
Imin = min(min(img(:,:,1)));

detectedIndices = [];
binaryIMG = zeros(rows, cols);

k=1;
for i = 1:rows
    for j = 1:cols
        %Binariza��o por threshold
        if img(i, j) >= (thresholdFactor * (Imax - Imin) + Imin) 
            detectedIndices = [detectedIndices; i, j];
            binaryIMG(i,j) = 1;
            
            boatPixelValue(k) = img(i, j);
            k = k + 1;
        end
    end
end

end