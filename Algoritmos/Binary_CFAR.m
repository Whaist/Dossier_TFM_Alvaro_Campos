%% Função que transforma uma imagem GEOTIFF em binária utilizando CA-CFAR

function [binaryIMG,boatPixelValue] = Binary_CFAR(Image,thresholdFactor)


%Tamanho ajustavel da janela deslizante do CFAR depende do tamanho da
%imagem
dim = size(Image);
if dim(1) < 69
    windowSize = [ round(dim(1)/3), round(dim(1)/6) ];
elseif dim(1) >= 69 && dim(1) < 136
    windowSize = [ round(dim(1)/3), round(dim(1)/6) ];
elseif dim(1) > 136
    windowSize = [ round(dim(1)/6), round(dim(1)/12) ];
end

%Seleção da polarização, existem duas hipoteses pois em algumas das imagens
%apenas temos acesso a polarização que é VV
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

% Inicialização da matrix de thresholds
threshold = zeros(rows, cols);

% Calcular threshold para cada celula
for i = windowSize(1) + 1 : rows - windowSize(1)
    for j = windowSize(2) + 1 : cols - windowSize(2)
        sum = 0;
        for x = i - windowSize(1) : i + windowSize(1)
            for y = j - windowSize(2) : j + windowSize(2)
                sum = sum + img(x, y);
                dev(x,y) = img(x,y); 
            end
        end
        average = sum / (windowSize(1) * windowSize(2));
        deviation = std2(dev);
        
        threshold(i, j) = average * thresholdFactor;
    end
end

% Deteção
detectedIndices = [];
boatPixelValue = [];
k=1;
for i = windowSize(1) + 1 : rows - windowSize(1)
    for j = windowSize(2) + 1 : cols - windowSize(2)
        if img(i, j) > threshold(i, j)
            detectedIndices = [detectedIndices; i, j];
            boatPixelValue(k) = img(i, j);
            k = k + 1;
        end
    end
end
% Criar a imagem binária
binaryIMG = zeros(rows, cols);

%Retirar deteções fora da zona da embarcação, ou seja, como todas as
%embarcações estão centradas na imagem todas as deteções fora do quadrado
%central são ignoradas
for i = 1:size(detectedIndices,1)
    if (detectedIndices(i,1) >= floor(1/3*rows) && detectedIndices(i,1) <= round(2/3*rows) && ...
        detectedIndices(i,2) >= floor(1/3*rows) && detectedIndices(i,2) <= round(2/3*rows))
        binaryIMG(detectedIndices(i,1),detectedIndices(i,2)) = 1;
        aux(i,:) = detectedIndices(i,:);
    end
end

if size(detectedIndices,1) ~= 0
    detectedIndices = aux;
end
end