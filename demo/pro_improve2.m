function [e,k_select]=pro_improve2(dataset,data_cv,label_cv,class,fold,kmax)
%******************��������******************
[num,attri]=size(dataset.data);

NT=ceil(num/fold); %����������
e1=zeros(fold,1);
e=0;

theta=2.5;

k_select=zeros(kmax,1);%��ѡkֵ

for t=1:fold
    if t>1&&t<fold
        num1=num-NT; %ѵ��������������������Ϊceil(num/fold)
        
        data_n=zeros(num1,attri);
        label_n=zeros(num1,1);
        data_n(1:(t-1)*NT,:)=data_cv(1:(t-1)*NT,:);
        data_n(((t-1)*NT+1):num1,:)=data_cv(t*NT+1:num,:);
        label_n(1:(t-1)*NT,:)=label_cv(1:(t-1)*NT,:);
        label_n(((t-1)*NT+1):num1,:)=label_cv(t*NT+1:num,:);
        
        data_nt=data_cv(((t-1)*NT+1):t*NT,:);
        label_nt=label_cv(((t-1)*NT+1):t*NT,:);
        
    elseif t==1
        num1=num-NT; %ѵ��������������������Ϊceil(num/fold)
        
        data_n=zeros(num1,attri);
        label_n=zeros(num1,1);
        data_n(1:num1,:)=data_cv(NT+1:num,:);
        label_n(1:num1,:)=label_cv(NT+1:num,:);
        
        data_nt=data_cv(1:NT,:);
        label_nt=label_cv(1:NT,:);
        
    elseif t==fold
        num1=NT*(t-1); %ѵ�������������һ�۲������������ܲ���ceil(num/fold)
        
        data_n=zeros(num1,attri);
        label_n=zeros(num1,1);
        data_n(1:num1,:)=data_cv(1:num1,:);
        label_n(1:num1,:)=label_cv(1:num1,:);
        
        data_nt=data_cv(num1+1:num,:);
        label_nt=label_cv(num1+1:num,:);
    end
    N=num1;
    NT=num-num1; %ǰfold-1��ʱ��������������Ϊ�����趨��ceil(num/fold)�����һ��ʱ�����ܻ��С������������
    
    fault=0;
    
    for x=1:NT
        data=data_nt(x,:);
        label=label_nt(x,:);
    %*************������ѵ����������*************   
        d=zeros(N);
        for i=1:N
            d(i)=pdist2(data_n(i,:),data);
        end
     %*************ѵ��������������������**********  
        [d_sort,I]=sort(d);
        data_n_sort=zeros(N,attri);
        label_n_sort=zeros(N,1);
        for i=1:N
            data_n_sort(i,:)=data_n(I(i),:);
            label_n_sort(i,:)=label_n(I(i));
        end
        
        %�Ľ�j
        %**********��ͬkֵ�£���ѡ���ڵ������Ӧ��Ŀ,������ռȫ�����ڱ���,��������ζ��������***********
        class_num=zeros(kmax,class);%��ͬkֵ�£���ѡ�����У���ͬ�����Ŀ
        class_num_sort=zeros(kmax,class);
        local_mean=zeros(class,attri);%��ǰkֵ�£���ͬ����ڵľֲ�����
        d_local_mean=1./zeros(kmax,class);%��ͬkֵ�£���ͬ����ڵľֲ����������������ľ���
        
        major=zeros(kmax,1);%��ͬkֵ�£����������
        minor=zeros(kmax,1);%��ͬkֵ�£��ζ��������
        
        relevance=zeros(kmax,1);%��ͬkֵ�£����������
        relevance_ratio=zeros(kmax,1);%��ͬkֵ�£�������ռȫ�����ڱ���
        d_relevance_local_mean=zeros(kmax,1);%��ͬkֵ�£�������������������������

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
            
            %�Ľ�k
            %������ʹζ������ѡ��
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
            
            %�������ѡ��
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

        %***********ѡ���������������ֲ�ռ��������ʱ��Ӧ��kֵ����Ϊ����Ӧkֵ**********
        %�Ľ�a
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

        %*******������*********
        if label_esti~=label
            fault=fault+1;
        end
    end
    e1(t)=fault/NT;
    
end

%*****ƽ��������**********

for i=1:fold
    e=e+e1(i);
end

e(:)=e(:)*100/fold;    
k_select(:)=k_select(:)*100/(num);


