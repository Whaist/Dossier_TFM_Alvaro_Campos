%% Global Threshold
% Função que transforma uma imagem GEOTIFF em binária utilizando apenas um Threshold

% Recebe a Imagem e o respetivo threshold
% Retorna a Imagem binarizada e um array com o valor dos pixeis detetados

function [binaryIMG,boatPixelValue] = Binary_TH(Image, thresholdFactor)

%Seleção da polarização, existem duas hipoteses pois em algumas das imagens
%apenas temos acesso a polarização que é VV
dim = size(Image);
if(length(dim) > 2)
    img(:,:,1) = Image(:,:,2);
    img(:,:,2) = Image(:,:,2); %Polarização VV
    img(:,:,3) = Image(:,:,2);
else
    img(:,:,1) = Image;
    img(:,:,2) = Image; %Polarização VV
    img(:,:,3) = Image;
end

[rows, cols] = size(img(:,:,1));

% Inicialização da matrix de tresholds
threshold = zeros(rows, cols);



Imax =max(max(img(:,:,1)));
Imin = min(min(img(:,:,1)));

detectedIndices = [];
binaryIMG = zeros(rows, cols);

k=1;
for i = 1:rows
    for j = 1:cols
        %Binarização por threshold
        if img(i, j) >= (thresholdFactor * (Imax - Imin) + Imin) 
            detectedIndices = [detectedIndices; i, j];
            binaryIMG(i,j) = 1;
            
            boatPixelValue(k) = img(i, j);
            k = k + 1;
        end
    end
end

end