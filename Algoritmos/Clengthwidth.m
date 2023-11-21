%% Vessel Measurement algorithm
% Função para obter valores calculados de Length e Width

% Recebe o caminho para a imagem, o threshold respetivo e o tipo de
% binarização.
% Retorna a dimensão da embarcação (length e width obtida dos dois algoritmos,
% o desvio padrão, a media, a Flag e o coeficiente de bimodalidade 

function [dimension, stdev, media, bimodalityF, bimodalityC] = Clengthwidth(Imagepath, Threshold, binaryzationType)

IMG = imread(Imagepath);

[rows, columns, numberOfColorChannels] = size(IMG);


% Criar a imagem binarizada
if binaryzationType == 0        %CFAR
    [binaryImage,boatPixelValue] = Binary_CFAR(IMG,Threshold);
elseif binaryzationType == 1    %TH algorithm
    [binaryImage,boatPixelValue] = Binary_TH(IMG, Threshold);
else
    disp('Erro tipo de binarização não encontrado');
    return
end

% Obter orientação da embarcação:
props = regionprops(binaryImage, 'Orientation', 'Centroid','MajorAxisLength','MinorAxisLength');
allOrientations = [props.Orientation];

%Verifica se a função deteta mais que um aglomerado de pixeis
if(length(props) ~= 1)
    dimension = [0 ; 0 ; 0 ; 0];
    stdev = 0;
    media = 0;
    bimodalityF = 0;
    bimodalityC = 0;
    return 
end

% Produz o grafico com o centro
for k = 1 : length(props)
  centerx = props(k).Centroid(1);
  centery = props(k).Centroid(2);
  
  
  %Linha sobre a orientação da embarcação
  lineLength = 20;
  angle =- 1*allOrientations(k);
  x2(1) =centerx;
  y2(1) =centery;
  x2(2) = x2(1) - lineLength * cosd(angle);
  y2(2) = y2(1) - lineLength * sind(angle);
  %continuation of the line
  x3(1) = centerx;
  y3(1) = centery;
  x3(2) = x3(1) + lineLength * cosd(angle);
  y3(2) = y3(1) + lineLength * sind(angle);

end

%improfile vai buscar os pixeis que se encontram por baixo da linha central
%do barco
[BinaryImageLx, BinaryImageLy, PixelUnderTheLineL] = improfile(binaryImage, [x2(2) x3(2)], [y2(2) y3(2)]);


%Criar os parametros de bimodalidade
bimodArray = [];
j=1;
for i = 1:size(PixelUnderTheLineL,1)
    if PixelUnderTheLineL(i) == 1
        bimodArray(j) = IMG(round(BinaryImageLx(i,1)),round(BinaryImageLy(i,1)));
        j=j+1;
    end 
end

[bimodalityF, bimodalityC] = bimodalitycoeff(bimodArray);

%----------------- calcula a length da embarcação -----------------%
%Length calculada pelo Linear equation algorithm
shipLength = sum(PixelUnderTheLineL == 1) * 10 %10 Pixel Spacing para as imagens GRD do sentinel-1

%Length calculada pelo region props
shipLength2 = props.MajorAxisLength*10


%----------------- criar a reta perpendicular y = ax + b -----------------
aLength = tand(-1*allOrientations(1));                         %a length (declive da reta que produz a length)
if aLength == 0 
    x1Width = centerx;                                            % --------
    x2Width = centerx;                                            % Valores para criar a Reta
    y1Width = lineLength;                                         % perpendicular a direção do barco
    y2Width = -lineLength;                                        % --------
else
    aWidth = -1/aLength;                                        %a width (declive da reta que produz a width)
    thethaWidth = atand(aWidth);                                %Angulo width
    bWidth = props(1).Centroid(2) - aWidth * props(1).Centroid(1);    %b width
    x1Width = x2(2);                                            % --------
    x2Width = x3(2);                                            % Valores para criar a Reta
    y1Width = aWidth * x1Width + bWidth;                        % perpendicular a direção do barco
    y2Width = aWidth * x2Width + bWidth;                        % --------
end

%improfile vai buscar os pixeis que se encontram por baixo da linha central
%do barco
[BinaryImageWx, BinaryImageWy, PixelUnderTheLineW] = improfile(binaryImage, [x1Width x2Width], [y1Width y2Width]);


%-----------------calcula a Width da embarcação-----------------%

shipWidth = sum(PixelUnderTheLineW == 1) * 10 %10 Pixel Spacing para as imagens GRD do sentinel-1
shipWidth2 = props.MinorAxisLength*10

media = mean(boatPixelValue);
stdev = std(boatPixelValue);

% Para ver os gráficos do coeficiente de bimodalidade é preciso descomentar
% as linhas a baixo

% %testes para bimodalidade
% figure;
% % plot the histograms
% subplot(1, 2, 1)
% histogram(bimodArray, 'FaceColor', 'b')
% ylim([0 50])
% grid minor
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
% xlabel('Value')
% ylabel('Frequency')
% % set axes background in green or red depending on BF
% % - green for bimodality and red for non-bimodality
% if bimodalityF
%     set(gca, 'Color', 'g')
% else
%     set(gca, 'Color', 'r')
% end   
% subplot(1, 2, 2)
% histogram(bimodArray, 'FaceColor', 'b')
% ylim([0 50])
% grid minor
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
% xlabel('Value')
% ylabel('Frequency')
% title(['Bimodality coeff. = ' num2str(bimodalityC)])
% % set axes background in green or red depending on BF
% % - green for bimodality and red for non-bimodality
% if bimodalityF
%     set(gca, 'Color', 'g')
% else
%     set(gca, 'Color', 'r')
% end   

        
dimension = [shipLength ; shipWidth; shipLength2; shipWidth2];
end