function [Y,Y_dat]  = makeEMGNMFOhta(X,kf,nrep,nshuffle,alg,normalization_method)
%Y contains information such as the contribution rate of muscle synergies and the contribution rate after shuffling. Y_dat contains the width (W) and height (H) of muscle synergies for each muscle synergy number.
% [Y,Y_dat] = makeEMGNMF(X,kf,nrep,nshuffle,alg);
% 
% kf: Number of k-fold cross-validation segments (k). Data is divided into k segments, with one used for testing and the others for training.
% Therefore, values like Y.train.r2 are generated k times; the final result is the average of these.
% kf=1 means no cross-validation is performed.
% 
% Example
% [Y,Y_dat]  = makeEMGNMF(X,4,10,1,ÅemultÅf);
% X: Filtered EMG data (rows: channels, columns: time series)

if(nargin<2)
    kf          = 4;  %This value determines whether cross-validation is performed and, if so, the number of splits.
    nrep        = 5;
    nshuffle    = 1;
    alg         = 'mult';   % 'mult' or 'als'
elseif(nargin<3)
    nrep        = 10;
    nshuffle    = 1;
    alg         = 'mult';
elseif(nargin<4)
    nshuffle    = 1;
    alg         = 'mult';
elseif(nargin<5)
    alg         = 'mult';
end

% Transpose for NMF
[mm,nn]   = size(X);    % mm channels x nn data length

if kf > 1 %When performing cross-validation
    Y_dat.train.W     = cell(mm,kf);
    Y_dat.train.H     = cell(mm,kf);
    Y_dat.train.D     = cell(mm,kf);
    Y_dat.test.W     = cell(mm,kf);
    Y_dat.test.H     = cell(mm,kf);
    Y_dat.test.D     = cell(mm,kf);
    
    
    Y.nrep      = nrep;
    Y.nshuffle  = nshuffle;
    Y.algorithm = alg;
    Y.train.latent       = nan(mm,kf);
    Y.train.explained    = nan(mm,kf);
    Y.train.r2           = nan(mm,kf);
    Y.train.r2slope      = nan(mm,kf);
    Y.test.latent        = nan(mm,kf);
    Y.test.explained     = nan(mm,kf);
    Y.test.r2            = nan(mm,kf);
    Y.test.r2slope       = nan(mm,kf);
else 
    Y_dat.W     = cell(mm,kf);
    Y_dat.H     = cell(mm,kf);
    Y_dat.D     = cell(mm,kf);

    Y.nrep      = nrep;
    Y.nshuffle  = nshuffle;
    Y.algorithm = alg;
    Y.latent       = nan(mm,kf);
    Y.explained    = nan(mm,kf);
    Y.r2           = nan(mm,kf);
    Y.r2slope      = nan(mm,kf);
end

X   = normalize(X,normalization_method);
 
for ii=1:mm %mm:Number of EMGs used (number of muscle synergies)
    disp([num2str(ii),'/',num2str(mm),' number of NMF'])
    % k-fold cross-validation
    if kf > 1 
        kfind   = false(kf,nn); %Create a logical value of size kf*nn and assign it to kfind.
        for ikf=1:kf
            kfind(ikf,((ikf-1)*floor(nn./kf)+1):(ikf*floor(nn./kf))) = true; %When kf = 4, a logical value of 1 appears in the first quarter of the first row, and a logical value of 1 appears in the first half of the second row (1/4 + 1).
        end
    
        for ikf=1:kf
            disp([num2str(ikf),'/',num2str(kf),' k-fold cross-validation'])
            
            % train
    
            XX  = X(:,~kfind(ikf,:)); %When splitting, the majority data is included (e.g., 3/4 of the data in a 4-way split)
            XX  = normalize(XX,normalization_method); %Normalized by the average of the new data
           [Y_dat.train.W{ii,ikf},Y_dat.train.H{ii,ikf},Y_dat.train.D{ii,ikf}]   = nnmf2(XX,ii,[],[],nrep,alg,'wh',normalization_method); %NMF incorporating multiplicative update rules
   
    
            
             
             Xhat            = Y_dat.train.W{ii,ikf}*Y_dat.train.H{ii,ikf}; %Reconstructed EMG from the final W and H
            E               = Xhat-XX; %Difference between measured EMG and reconstructed EMG
            SSE             = sum(reshape(E,numel(E),1).^2);
            SST             = sum((reshape(XX,numel(XX),1)-mean(mean(XX))).^2);
            Y.train.r2(ii,ikf)        = 1 - SSE./SST;     % Roh et al (2010) JNP (Variance accounted for by the final muscle synergies)
            
           % Xvar            = var(reshape(XX,numel(XX),1),0);
             Xvar = sum(var(XX,1,2)); %Sum of variances of measured EMG across all muscles
           %Y.train.latent(ii,ikf)    = var(reshape(Xhat,numel(Xhat),1),0);
             Y.train.latent(ii,ikf) = sum(var(Xhat,1,2)); %Sum of variances of reconstructed EMG across all muscles
           Y.train.explained(ii,ikf) = Y.train.latent(ii,ikf) / Xvar; %Explained variance ratio (reconstructed EMG variance / measured EMG variance)
            
            % test
            
            XX  = X(:,kfind(ikf,:));
            XX  = normalize(XX,normalization_method);
             [Y_dat.test.W{ii,ikf},Y_dat.test.H{ii,ikf},Y_dat.test.D{ii,ikf}]   = nnmf2(XX,ii,Y_dat.train.W{ii,ikf},[],nrep,alg,'wh','none');
    %        [Y_dat.test.W{ii,ikf},H]   = nnmf2(XX,ii,Y_dat.train.W{ii,ikf},[],nrep,alg,'h','none');
            
             Xhat            = Y_dat.test.W{ii,ikf}*Y_dat.test.H{ii,ikf};
    %        Xhat            = Y_dat.test.W{ii,ikf}*H;
            E               = Xhat-XX;
            SSE             = sum(reshape(E,numel(E),1).^2);
            SST             = sum((reshape(XX,numel(XX),1)-mean(mean(XX))).^2);
            Y.test.r2(ii,ikf)        = 1 - SSE./SST;     % Roh et al (2010) JNP
            
           % Xvar            = var(reshape(XX,numel(XX),1),0);
            Xvar = sum(var(XX,1,2));
           % Y.test.latent(ii,ikf)    = var(reshape(Xhat,numel(Xhat),1),0);
            Y.test.latent(ii,ikf)    = sum(var(Xhat,1,2));
           Y.test.explained(ii,ikf) = Y.test.latent(ii,ikf) / Xvar;
            
            
            
            
        end
    else
        XX  = X; %Assign X to XX in order to use the cross-validation template
        XX  = normalize(XX,normalization_method); %Normalize using the mean of the current dataset
        [Y_dat.W{ii,1},Y_dat.H{ii,1},Y_dat.D{ii,1}]   = nnmf2(XX,ii,[],[],nrep,alg,'wh',normalization_method); %NMF implementation including multiplicative update rule
        %[Y_dat.train.W{ii,1},H]   = nnmf2(XX,ii,[],[],nrep,alg,'wh',normalization_method);
        %Y_datÅ®trainÅ®W{number of synergies,1} stores spatial bases for each synergy number (only one column since the dataset is not split)
        Xhat = Y_dat.W{ii,1}*Y_dat.H{ii,1}; %Reconstructed EMG from the final W and H
        %Xhat= Y_dat.train.W{ii,ikf}*H;
        E = Xhat-XX; %Difference between measured EMG and reconstructed EMG
        SSE = sum(reshape(E,numel(E),1).^2);
        SST = sum((reshape(XX,numel(XX),1)-mean(mean(XX))).^2);
        Y.r2(ii,1) = 1 - SSE./SST;     % Roh et al (2010) JNP
            
       % Xvar            = var(reshape(XX,numel(XX),1),0);
       Xvar = sum(var(XX,1,2));
       %Y.train.latent(ii,ikf)    = var(reshape(Xhat,numel(Xhat),1),0);
       Y.latent(ii,1) = sum(var(Xhat,1,2)); 
       Y.explained(ii,1) = Y.latent(ii,1) / Xvar;
    end
end

if kf > 1 %If cross-validation is performed
    Y.train.r2slope  = [Y.train.r2(1,:); diff(Y.train.r2,1,1)];
    Y.test.r2slope   = [Y.test.r2(1,:); diff(Y.test.r2,1,1)];
else %If cross-validation is not performed
    Y.r2slope  = [Y.r2(1,:); diff(Y.r2,1,1)];
end

if(nshuffle>0)
% Shuffle also performs train-test evaluation, but only the test data results are stored.

    Y.shuffle.latent    = nan(mm,kf,nshuffle);  
    Y.shuffle.explained = nan(mm,kf,nshuffle);
    Y.shuffle.r2        = nan(mm,kf,nshuffle);
    Y.shuffle.r2slope   = nan(mm,kf,nshuffle);
    
    for ishuffle=1:nshuffle
        disp(['shuffle: ',num2str(ishuffle),'/',num2str(nshuffle)])
        Xshuf  = X;
        
        for ii=1:mm
            Xshuf(ii,:)    = X(ii,randperm(nn));
        end
        
    %     Xvar    = var(reshape(Xshuf,numel(Xshuf),1),0);
    
        for ii=1:mm
            disp(['shuffle: ',num2str(ii),'/',num2str(mm)])
            
            
            % k-fold cross-validation
            if kf > 1
                kfind   = false(kf,nn);
                for ikf=1:kf
                    kfind(ikf,((ikf-1)*floor(nn./kf)+1):(ikf*floor(nn./kf))) = true;
                end
                
                for ikf=1:kf
                    disp([num2str(ikf),'/',num2str(kf),' k-fold cross-validation'])
                    
                    % train
                    XX  = Xshuf(:,~kfind(ikf,:));
                    XX  = normalize(XX,normalization_method);
                    [W,H]   = nnmf2(XX,ii,[],[],nrep,alg,'wh',normalization_method);
                    
                    % test
                    XX  = Xshuf(:,kfind(ikf,:));
                    XX  = normalize(XX,normalization_method);
                    [W,H]   = nnmf2(XX,ii,W,[],nrep,alg,'h','none');
                    
                    
                    Xhat            = W*H;
                    E               = Xhat-XX;
                    SSE             = sum(reshape(E,numel(E),1).^2);
                    SST             = sum((reshape(XX,numel(XX),1)-mean(mean(XX))).^2);
                    Y.shuffle.r2(ii,ikf,ishuffle)        = 1 - SSE./SST;     % Roh et al (2010) JNP
                    
                    %Xvar            = var(reshape(XX,numel(XX),1),0);
                    Xvar = sum(var(XX,1,2));
                    %Y.shuffle.latent(ii,ikf,ishuffle)    = var(reshape(Xhat,numel(Xhat),1),0);
                    Y.shuffle.latent(ii,ikf,ishuffle)     = sum(var(Xhat,1,2));
                    Y.shuffle.explained(ii,ikf,ishuffle) = Y.shuffle.latent(ii,ikf,ishuffle) / Xvar;                
                end
            else
                 disp('No-cross-validation')
                    
                    % train
                    XX  = Xshuf;
                    XX  = normalize(XX,normalization_method);
                    [W,H]   = nnmf2(XX,ii,[],[],nrep,alg,'wh',normalization_method);
                    Xhat            = W*H;
                    E               = Xhat-XX;
                    SSE             = sum(reshape(E,numel(E),1).^2);
                    SST             = sum((reshape(XX,numel(XX),1)-mean(mean(XX))).^2);
                    Y.shuffle.r2(ii,1,ishuffle)        = 1 - SSE./SST;     % Roh et al (2010) JNP
                    
                    %Xvar            = var(reshape(XX,numel(XX),1),0);
                    Xvar = sum(var(XX,1,2));
                    %Y.shuffle.latent(ii,ikf,ishuffle)    = var(reshape(Xhat,numel(Xhat),1),0);
                    Y.shuffle.latent(ii,1,ishuffle)     = sum(var(Xhat,1,2));
                    Y.shuffle.explained(ii,1,ishuffle) = Y.shuffle.latent(ii,1,ishuffle) / Xvar; 
            end  
        end
        Y.shuffle.r2slope(:,:,ishuffle) = [Y.shuffle.r2(1,:,ishuffle); diff(Y.shuffle.r2(:,:,ishuffle),1,1)];
    end
end

