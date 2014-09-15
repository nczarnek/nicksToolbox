classdef dkDsClass
    
    properties (Dependent=true)
        X=[];
        Y=[];
        
        
    end
    
    properties (SetAccess=protected)
        data=[];
        targets=[];
        nObs=[];
        nClasses=[];
        trained=false;
        observationInfo=struct;
    end
    
    methods
        
        function out= get.X(self)
            out=self.data;
        end
        
        function out = get.Y(self)
            out=self.targets;
        end
        function self = set.X(self,val)
            
            %if size(self.Y,1)==size(val,1)||size(self.Y,1)==0;
            self.data = val;
            % else
            %                error('Inconsistent number of observations')
            %end
            self.nObs=size(self.X,1);
            self.nClasses=size(self.X,2);
        end
        
        function self = set.Y(self,val)
            
            if size(self.X,1)==size(val,1)
                self.targets = val;
            elseif size(val,1)==0
                self.targets=[];
            else
                error('Inconsistent number of observations')
            end
        end
        
        
        
        
        
        function out = keepClass(self,val)
            
            out=dkDsClass(self.X(:,val),self.Y,self.observationInfo);
            
            
        end
        
        function out = keepObs(self,val)
            
            out=dkDsClass(self.X(val,:),self.Y(val,:),retainStructInds(self.observationInfo,val));
            
        end
        
        function self = dkDsClass(data,targets,observationStruct)
            if nargin >=1
                self.X=data;
                
            end
            if nargin>=2
               
                self.Y=targets;
                if size(data,1)~=size(targets,1) && size(targets,1)~=0
                    error('nObservations is inconsistent');
                end
            end
            if nargin==3
                self.observationInfo = observationStruct;
                
            end
                
              
            
        end
        
        function plotData(self)
            nFeats=size(self.X,2);
            if isempty(self.Y)
                if nFeats>2
                    error('Data > 2 Dims')
                elseif nFeats==2
                    scatter(self.X(:,1),self.X(:,2));
                elseif nFeats==1
                    scatter(self.X)
                    
                end
                legend('Unlabeled')
            else
                
                if nFeats>2
                    error('Data > 2 Dims')
                elseif nFeats==2
                    scatter(self.X(self.Y==0,1),self.data(self.Y==0,2),'bo')
                    hold on
                    scatter(self.X(self.Y==1,1),self.data(self.Y==1,2),'rx')
                elseif nFeats==1
                    
                    h0=self.X(self.Y==0,1);
                    h1=self.X(self.Y==1,1);
                    
                    scatter(h0,zeros(size(h0,1),1),'bo')
                    hold on
                    scatter(h1,ones(size(h1,1),1),'rx')
                end
                legend('Miss','Hit')
            end
            xlabel('Feauture 2')
            ylabel('Feature 1')
        end
        function plotDensity(self)
            if size(self.X,2)~=1
                error('More than 1 Dim features.. cannot plot density')
                %In the future, be able to plot multiple ROC's
            end
            
            %% plot H0
            cData=self.X(self.Y==0,1);
            xRange=linspace(min(self.X(:,1)),max(self.X(:,1)),size(self.X,1)/20);
            N = hist(cData,xRange);        %# Bin the data
            
            plot(xRange,N./numel(cData));  %# Plot the probabilities for each integer
            xlabel('Confidence');
            ylabel('Probability');
            
            hold on
            
            cData=self.X(self.Y==1,1);
            xRange=linspace(min(cData(:,1)),max(cData(:,1)),size(cData,1)/20);
            N = hist(cData,xRange);        %# Bin the data
            
            plot(xRange,N./numel(cData),'r');  %# Plot the probabilities for each integer
            legend('Miss','Hit')
            
            
            %% plot H1
            
        end
        
        function [pf,pd,AUC] = plotRoc(self)
            if size(self.X,2)~=1
                error('More than 1 Dim features.. cannot plot ROC')
                %In the future, be able to plot multiple ROC's
            end
            
            [~, sortedInd] = sort(self.X,'descend');
            sortedY = self.Y(sortedInd);
            
            missInd = double(~sortedY);
            hitInd = double(sortedY);
            
            nH1 = sum(missInd);
            nH0 = length(hitInd)-nH1;
            
            pd = cumsum(hitInd)/nH1;
            pf = cumsum(missInd)/nH0;
            
            pd = cat(1,0,pd);
            pf = cat(1,0,pf);
            
           plot(pf,pd)
            AUC=trapz(pf,pd);
            xlabel('PF')
            ylabel('PD')
            
        end
        
        function decRegion(self)
            if ~self.trained
                error('Classifier is not trained')
            else
                x1 = linspace(min(self.X(:,1))*0.8, max(self.X(:,1))*1.2,251);
                x2 = linspace(min(self.X(:,2))*0.8, max(self.X(:,2))*1.2,251);
                % Create the grid of test data points
                [xTest1,xTest2] = meshgrid(x1,x2);
                xTest = [xTest1(:) xTest2(:)]; % Each column is a feature
                % Run the classifier with these test data
                cDs=dkDsClass(xTest);
                
                dsTest = testClass(self,cDs);
                
                % dsTest is a vector, reshape it to a matrix
                
                dsTest.X = reshape(dsTest.X,length(x2),length(x1));
                
                % Image the decision statistic surface
                
                imagesc(x1(1:end),x2(1:end), dsTest.X)
                xlabel('Feauture 2')
                ylabel('Feature 1')
                % Add the training data points to the surface
                
                hold on
                plot(self.X(self.Y==0,1),self.X(self.Y==0,2),'b*')
                
                % H0
                
                plot(self.X(self.Y==1,1),self.X(self.Y==1,2),'ro')
                
            
            end
            
        end
        
        function yOut = crossValidateRand(self,classIn,nFolds)
            keys=cumsum(ones(nFolds,ceil(self.nObs/nFolds)),1);
            keys=keys(:);
            keys=keys(1:self.nObs);
            keys=keys(randperm(length(keys)));
            
            yOut=self;
            yOut.X=yOut.X(:,1);
            for iFold=1:nFolds
                
                dsTrain=trainClass(classIn,self.keepObs(keys~=iFold));
                outTemp=testClass(dsTrain,self.keepObs(keys==iFold));
                yOut.X(keys==iFold,1)=outTemp.X;
                
            end
        end
        
         function yOut = crossValidateWithKeys(self,classIn,keys)
            
            if size(keys,1)~=self.nObs
               
                error('Key size is different than nObs')
                
            end
            yOut=self;
            yOut.X=yOut.X(:,1);
            nFolds=size(unique(keys),1);
            
            for iFold=1:nFolds
                
                dsTrain=trainClass(classIn,self.keepObs(keys~=iFold));
                outTemp=testClass(dsTrain,self.keepObs(keys==iFold));
                yOut.X(keys==iFold,1)=outTemp.X;
                
            end
         end
        
           function out = trainTest(self,classIn)
               
            out = testClass(trainClass(classIn,self),self);
            
        end
    end
end