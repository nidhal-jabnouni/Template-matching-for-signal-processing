% ==== pre-processing de signaux radio par spectrogramme ===============
% ===== + filtre convolutionnel pour d√©tection de tweeks (par R. Amara 17/03) ===== 
%==================================================================================

clear all

for p=20:50,% p: indice de trame 
close all

load tweeks; %le signal ‡ traiter
length_frame=10000;%taille de chaque trame
data1=data(p*length_frame:(p+1)*length_frame); % data1 contient la trame de l'indice p √† l'indice p+1
%data1=data1(1:length(data1)/2);
NFFT=512;% nbre d'Èchantillons utilisÈs par la FFT
window=NFFT/4;% longueur de segment pour le spectrogramme 
noverlap=floor(window*0.7); % nbre de chevauchements de chaque segment de data1
data1=data1-mean(data1); %trame centrÈe
%data1=data1/max(abs(data1));

% faire le help de la fct spectrogram et indiquer ses inputs et outputs
% .....................................................................
[Y,F,T,P]=spectrogram(data1,window,noverlap,NFFT,Fs); % pr√©ciser c'est quoi Y : contenu frÈquentiel ‡ court terme,
%P : Matrice des puissances,
%F : Vecteur des frÈquences,
%T : Vecteur des temps
P1=10*log10(abs(P));% calcul de  la PSD en √©chelle logarithmique
P1(P1<-40)=-40;%forcer le minimum ‡ Ítre -40 dB
subplot(2,1,1);surf(T,F,P1,'Edgecolor','none') % afficher la PSD
axis xy; axis tight; colormap(jet); view(0,90);
title('Spectrogramme')
[nbre_line,nbre_column]=size(P); % les dimensions de la PSD
for k=1:nbre_column,
   energy_P(k)=mean(P(50:nbre_line,k)); % calcul de l'Ènergie moyenne 
   %fournir une expression th√©orique de energy_P : energy_P = 1/n *(0,..,0,1,..,1)*P
   %avec 50 zeros
end
subplot(2,1,2);plot(10*log10(energy_P)) % afficher l'Ènergie
title('Energie calcul√©e √† partir du spectrogramme')
pause(2); % arr√™ter l'ex√©cution pendant 2 sec pour afficher les graphes

% Choix du filtre convolutionnel (expliquer pourquoi est-il d√©sign√© comme
% √ßa: pour detecter les puissances trÈs ÈlevÈes
%========= essayer plusieurs valeurs pour le filtre convolutionnel ; vous
%======pouvez en sugg√©rer d'autres ; et pr√©ciser ceux qui vous donnent le
%======meilleur r√©sultat======================================
%patch =[1   1;1   1]*0.25;
%patch=[1;1;1;1];
%patch =[1   1 1;1  1  1;1 1 1];
%patch=[2;5;10;5;2];
%patch=[-1 -1;1 1;-1 -1];
%patch=[-2;-1;1;-1;-2];
%patch=[-1;10;-1];
%patch=[1/2;1;1/2];
%== gaussian patch==============
% x= -1:0.1:1;
% y=-1:0.1:1;
% patch=1/sqrt(2*pi)*exp(-1/2*x.^2);
% patch=patch';
% for i=1:length(x),
%    for j=1:length(y),
% patch(i,j)=1/sqrt(2*pi)*exp(-1/2*(x(i)^2+y(j)^2));
%    end
% end

%new patch
patch = zeros(floor(0.8*nbre_line), 6);
for i=1:floor(0.8*nbre_line),
    for j=1:3;
        patch(i,j)=1;
    end
    if(i > floor(0.94*nbre_line*0.8))
        for j=4:6;
            patch(i,j)=1;
        end
    end
        
end

%=========================
[L,LL]=size(patch);
FF = zeros(nbre_line-L, nbre_column-LL);

for i=1:nbre_line-L,
    for j=1:nbre_column-LL;
        FF(i,j)=sum(sum(patch.*P1(i:(i+L-1),j:(j+LL-1)))); 
        %donner une expression formul√©e math√©matiquement pour le calcul de FF
        %FF =conv(patch,Pl)
    end
end
pause(1);
FF(FF<-20)=-20; %forcer le minimum ‡ Ítre -20 dB
figure
subplot(3,1,1);surf(FF(1:min(250,nbre_line-L) ,1:min(250,nbre_column-LL)),'Edgecolor','none') % affichage de FF
axis xy; axis tight; colormap(jet); view(0,90);
title('FF')
for k=1:200,
energy(k)=mean(FF(50:min(200,nbre_line-L),k)); 
end
label = uint8(energy > -20);
subplot(3,1,2);plot(energy);

title('Energie bas√©e sur le spectrogramme pr√©-trait√©')
subplot(3,1,3);plot(label);
title('tweeks');
pause(2)
 end
%==== compl√©ter le code pour la d√©tection intelligente des temps d'arriv√©e
%=== des sferics (un vecteur TOA) et pour l'identification de sferics de
%type tweeks : g√©n√©rer un vecteur label contenant 0 sur la fen√™tre (window) ne contenant pas un
%tweek et 1 si fen√™tre analys√©e correspondant √† un tweek)..........
%.........................................................


