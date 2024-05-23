function [e,k_select]=pro_improve2(dataset,data_cv,label_cv,class,fold,kmax)
%******************读入数据******************
[num,attri]=size(dataset.data);

NT=ceil(num/fold); %测试样本数
e1=zeros(fold,1);
e=0;

theta=2.5;

k_select=zeros(kmax,1);%所选k值

for t=1:fold
    if t>1&&t<fold
        num1=num-NT; %训练样本数，测试样本数为ceil(num/fold)
        
        data_n=zeros(num1,attri);
        label_n=zeros(num1,1);
        data_n(1:(t-1)*NT,:)=data_cv(1:(t-1)*NT,:);
        data_n(((t-1)*NT+1):num1,:)=data_cv(t*NT+1:num,:);
        label_n(1:(t-1)*NT,:)=label_cv(1:(t-1)*NT,:);
        label_n(((t-1)*NT+1):num1,:)=label_cv(t*NT+1:num,:);
        
        data_nt=data_cv(((t-1)*NT+1):t*NT,:);
        label_nt=label_cv(((t-1)*NT+1):t*NT,:);
        
    elseif t==1
        num1=num-NT; %训练样本数，测试样本数为ceil(num/fold)
        
        data_n=zeros(num1,attri);
        label_n=zeros(num1,1);
        data_n(1:num1,:)=data_cv(NT+1:num,:);
        label_n(1:num1,:)=label_cv(NT+1:num,:);
        
        data_nt=data_cv(1:NT,:);
        label_nt=label_cv(1:NT,:);
        
    elseif t==fold
        num1=NT*(t-1); %训练样本数，最后一折测试样本数可能不到ceil(num/fold)
        
        data_n=zeros(num1,attri);
        label_n=zeros(num1,1);
        data_n(1:num1,:)=data_cv(1:num1,:);
        label_n(1:num1,:)=label_cv(1:num1,:);
        
        data_nt=data_cv(num1+1:num,:);
        label_nt=label_cv(num1+1:num,:);
    end
    N=num1;
    NT=num-num1; %前fold-1折时，测试样本数即为上面设定的ceil(num/fold)；最后一折时，可能会变小（不能整除）
    
    fault=0;
    
    for x=1:NT
        data=data_nt(x,:);
        label=label_nt(x,:);
    %*************输入与训练样本距离*************   
        d=zeros(N);
        for i=1:N
            d(i)=pdist2(data_n(i,:),data);
        end
     %*************训练样本按距离升序排列**********  
        [d_sort,I]=sort(d);
        data_n_sort=zeros(N,attri);
        label_n_sort=zeros(N,1);
        for i=1:N
            data_n_sort(i,:)=data_n(I(i),:);
            label_n_sort(i,:)=label_n(I(i));
        end
        
        %改进j
        %**********不同k值下，所选近邻的类别及相应数目,多数类占全部近邻比例,多数类与次多数类比例***********
        class_num=zeros(kmax,class);%不同k值下，所选近邻中，不同类的数目
        class_num_sort=zeros(kmax,class);
        local_mean=zeros(class,attri);%当前k值下，不同类近邻的局部质心
        d_local_mean=1./zeros(kmax,class);%不同k值下，不同类近邻的局部质心与输入样本的距离
        
        major=zeros(kmax,1);%不同k值下，多数类类别
        minor=zeros(kmax,1);%不同k值下，次多数类类别
        
        relevance=zeros(kmax,1);%不同k值下，关联类类别
        relevance_ratio=zeros(kmax,1);%不同k值下，关联类占全部近邻比例
        d_relevance_local_mean=zeros(kmax,1);%不同k值下，关联类质心与输入样本距离

        for k=1:kmax
            if k==1
                class_num(k,label_n_sort(k))=class_num(k,label_n_sort(k))+1;
                local_mean(label_n_sort(k),:)=(local_mean(label_n_sort(k),:)+data_n_sort(k,:))/class_num(k,label_n_sort(k));
                d_local_mean(k,label_n_sort(k))=pdist2(local_mean(label_n_sort(k),:),data);
            else
                class_num(k,:)=class_num(k-1,:);
                class_num(k,label_n_sort(k))=class_num(k,label_n_sort(k))+1;
                local_mean(label_n_sort(k),:)=(local_mean(label_n_sort(k),:)*(class_num(k,label_n_sort(k))-1)+data_n_sort(k,:))/class_num(k,label_n_sort(k));
                d_local_mean(k,:)= d_local_mean(k-1,:);
                d_local_mean(k,label_n_sort(k))=pdist2(local_mean(label_n_sort(k),:),data);
            end
            [class_num_sort(k,:),I]=sort(class_num(k,:),'descend');
            
            %改进k
            %多数类和次多数类的选择
            same_major=zeros(class,1);
            same_major(1)=I(1);
            same_major_num=1;
            
            same_minor=zeros(class,1);
            same_minor_num=0;
            
            for i=2:class
                if class_num_sort(k,i)==class_num_sort(k,1)
                    same_major_num=same_major_num+1;
                    same_major(i)=I(i);
                else
                    if class_num_sort(k,i)==class_num_sort(k,same_major_num+1)
                        same_minor_num=same_minor_num+1;
                        same_minor(i-same_major_num)=I(i);
                    end
                end
            end
            
            if same_major_num==1
                major(k)=same_major(1);
                
                if same_minor_num==1
                    minor(k)=I(2);
                else
                    d_same_minor_local_mean=zeros(same_minor_num,1);
                    for i=1:same_minor_num
                        d_same_minor_local_mean(i)=d_local_mean(k,same_minor(i));
                    end
                    [~,I_minor]=min(d_same_minor_local_mean);
                    minor(k)=same_minor(I_minor);
                end
                
            else
                    d_same_major_local_mean=zeros(same_major_num,1);
                    for i=1:same_major_num
                        d_same_major_local_mean(i)=d_local_mean(k,same_major(i));
                    end
                    [~,I_major]=sort(d_same_major_local_mean);
                    major(k)=same_major(I_major(1));
                    minor(k)=same_major(I_major(2));              
            end
            
            %关联类的选择
            if class_num(k,major(k))/class_num(k,minor(k)) >= theta
                relevance(k)=major(k);
            else
                if d_local_mean(k,major(k)) <= d_local_mean(k,minor(k))
                    relevance(k)=major(k);
                else
                    relevance(k)=minor(k);
                end
            end
            relevance_ratio(k)=class_num(k,relevance(k))/k;    
            d_relevance_local_mean(k)=d_local_mean(k,relevance(k));    
        end

        %***********选出关联类数量及分布占绝对优势时对应的k值，作为自适应k值**********
        %改进a
        relevance_ratio_sort=sort(relevance_ratio,'descend');
        I_ratio_temp=arrayfun(@(x) find(relevance_ratio(x)==relevance_ratio_sort),1:numel(relevance_ratio),'UniformOutput',false);
        d_relevance_local_mean_sort=sort(d_relevance_local_mean);
        I_d_temp=arrayfun(@(x) find(d_relevance_local_mean(x)==d_relevance_local_mean_sort),1:numel(d_relevance_local_mean),'UniformOutput',false);

        I_ratio=zeros(kmax,1);
        I_d=zeros(kmax,1);
        for k=1:kmax
            I_ratio(k)=I_ratio_temp{1,k}(1,1);
            I_d(k)=I_d_temp{1,k}(1,1);
        end
        
        score=I_ratio/max(I_ratio)+I_d/max(I_d);        
        [score_sort,I_all]=sort(score(2:20));
        
        label_esti=relevance(I_all(1)+1);
        k_select(I_all(1)+1)=k_select(I_all(1)+1)+1;

        %*******错误率*********
        if label_esti~=label
            fault=fault+1;
        end
    end
    e1(t)=fault/NT;
    
end

%*****平均错误率**********

for i=1:fold
    e=e+e1(i);
end

e(:)=e(:)*100/fold;    
k_select(:)=k_select(:)*100/(num);


