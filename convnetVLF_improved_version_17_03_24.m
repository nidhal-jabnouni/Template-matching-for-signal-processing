% ==== pre-processing de signaux radio par spectrogramme ===============
% ===== + filtre convolutionnel pour détection de tweeks (par R. Amara 17/03) ===== 
%==================================================================================

clear all

for p=20:50,% p: indice de trame 
close all

load tweeks; %le signal � traiter
length_frame=10000;%taille de chaque trame
data1=data(p*length_frame:(p+1)*length_frame); % data1 contient la trame de l'indice p à l'indice p+1
%data1=data1(1:length(data1)/2);
NFFT=512;% nbre d'�chantillons utilis�s par la FFT
window=NFFT/4;% longueur de segment pour le spectrogramme 
noverlap=floor(window*0.7); % nbre de chevauchements de chaque segment de data1
data1=data1-mean(data1); %trame centr�e
%data1=data1/max(abs(data1));

% faire le help de la fct spectrogram et indiquer ses inputs et outputs
% .....................................................................
[Y,F,T,P]=spectrogram(data1,window,noverlap,NFFT,Fs); % préciser c'est quoi Y : contenu fr�quentiel � court terme,
%P : Matrice des puissances,
%F : Vecteur des fr�quences,
%T : Vecteur des temps
P1=10*log10(abs(P));% calcul de  la PSD en échelle logarithmique
P1(P1<-40)=-40;%forcer le minimum � �tre -40 dB
subplot(2,1,1);surf(T,F,P1,'Edgecolor','none') % afficher la PSD
axis xy; axis tight; colormap(jet); view(0,90);
title('Spectrogramme')
[nbre_line,nbre_column]=size(P); % les dimensions de la PSD
for k=1:nbre_column,
   energy_P(k)=mean(P(50:nbre_line,k)); % calcul de l'�nergie moyenne 
   %fournir une expression théorique de energy_P : energy_P = 1/n *(0,..,0,1,..,1)*P
   %avec 50 zeros
end
subplot(2,1,2);plot(10*log10(energy_P)) % afficher l'�nergie
title('Energie calculée à partir du spectrogramme')
pause(2); % arrêter l'exécution pendant 2 sec pour afficher les graphes

% Choix du filtre convolutionnel (expliquer pourquoi est-il désigné comme
% ça: pour detecter les puissances tr�s �lev�es
%========= essayer plusieurs valeurs pour le filtre convolutionnel ; vous
%======pouvez en suggérer d'autres ; et préciser ceux qui vous donnent le
%======meilleur résultat======================================
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
        %donner une expression formulée mathématiquement pour le calcul de FF
        %FF =conv(patch,Pl)
    end
end
pause(1);
FF(FF<-20)=-20; %forcer le minimum � �tre -20 dB
figure
subplot(3,1,1);surf(FF(1:min(250,nbre_line-L) ,1:min(250,nbre_column-LL)),'Edgecolor','none') % affichage de FF
axis xy; axis tight; colormap(jet); view(0,90);
title('FF')
for k=1:200,
energy(k)=mean(FF(50:min(200,nbre_line-L),k)); 
end
label = uint8(energy > -20);
subplot(3,1,2);plot(energy);

title('Energie basée sur le spectrogramme pré-traité')
subplot(3,1,3);plot(label);
title('tweeks');
pause(2)
 end
%==== compléter le code pour la détection intelligente des temps d'arrivée
%=== des sferics (un vecteur TOA) et pour l'identification de sferics de
%type tweeks : générer un vecteur label contenant 0 sur la fenêtre (window) ne contenant pas un
%tweek et 1 si fenêtre analysée correspondant à un tweek)..........
%.........................................................


