
% MASC Free viewing  Demo

Apply_IOR = 1 ; % inhibition of return 
Apply_Retina_Transform = 1 ; % apply retina transformation
IOR_size = 121  ;  % the size of the IOR window  
IOR_sigma = 25 ;  % the sigma for the IOR window 
max_fix = 20 ; % set the total number of fixations 

% IOR filter
filt_disk = fspecial('disk',floor(IOR_size/2));
filt_IOR_1 = fspecial('gaussian', [IOR_size IOR_size], IOR_sigma)  ; 
filt_IOR = (filt_disk/max(filt_disk(:))) .* filt_IOR_1./max(filt_IOR_1(:));

% initial fixation location 
Init_row_im_f = 480 ;   % default 0  , 480 reading   , paragraph 145  , disk 301
Init_col_im_f = 136 ; 

%set which saliency model to use
Saliency_model = 1 ;  %  1:Itti without smoothing   2:Itti with Smoothing 

smooth_priority = 0 ;
use_foreground = 0 ;
RETINA_PIXDEG = 66.53 ;   % image pixels per one degree visual angle, depends on your data collection but leave it at this if not sure

% Eye Movement Generation Method
Saccade_model = 1;   %   1:MASC   2:Peak visiting (IK)  3: constant saccade model

%add jitter to the landing position
location_jitter = 1;

Reading = 1 ;
%Displays_dir = 'F:\TAM Eye Model\TAM_Gdrive\Sentence_Images\'; %'F:\TAM Eye Model\TAM_Gdrive\Images_filled-spaces\Images' ; %
Displays_dir = './Sentence_Images/' ; %'E:\Lenovo_transfer\F\TAM Eye Model\TAM_Gdrive\Sentence_Images\';
Image_files = dir(strcat(Displays_dir, '/*.bmp'));

% Output Parameters
save_output_maps = 1 ; % set to 1 if you want to save the output maps

save_fixations = 1 ;
results_dir = [pwd,'\run', num2str(Saccade_model),'\'] ; % set this to the directory where you want the output maps saved
%output_dir = 'E:\Lenovo_transfer\F\TAM Eye Model\TAM_Gdrive\Reading\Reading_Model_121_25_ave_1_j_6_12_2_layer_IOR_first_fixation_run20'
save_logs = 1 ;
save_Model_Data = 1;
save_Model_Data_excel = 1;
%Set the name of the output file here
Model_output_name = ['Reading_output_model_', num2str(Saccade_model)] ;

show_scanpath = 0 ;

% loop here for running this for more images
% im_address = '1.jpg';
% input_im = imread(im_address) ; % set this to your input image
% [filepath,image_name,ext] = fileparts(im_address);

%%
for trial_num = 1:length(Image_files)  %1:20 %   21:40 %   
    
    trial_num
            
    image_name = Image_files(trial_num).name 
    input_im = imread(fullfile(Displays_dir, image_name));
    Model_Data{trial_num,1}.filename = image_name ;
    
    output_dir = [results_dir,image_name] ;
    
    if (save_logs==1 || save_output_maps==1)
        if (~exist(output_dir))
            mkdir(output_dir)
        end
    end
    
    if (size(input_im,3) == 1)
        input_im = repmat(input_im,[1 1 3]);
    end
    
    if(Reading && Saccade_model == 3)
        left_limit = min(find(sum(sum(input_im,3),1)));
        right_limit =max(find(sum(sum(input_im,3),1)));
    end
    
    new_out = sprintf('%s/out.txt',output_dir) ;
    if(save_logs)
        fid = fopen(new_out,'w');
        fprintf(fid, '%s\n', image_name);
    end
    
    [im_h , im_w , im_d] = size(input_im) ;
    
    if( Init_row_im_f == 0 )
        row_im_f = floor(im_h/2) ;
        col_im_f = floor(im_w/2) ;
    else
        row_im_f = Init_row_im_f ;
        col_im_f = Init_col_im_f ;
    end
    
    Model_Data{trial_num,1}.scan_path(1,1) = row_im_f ;
    Model_Data{trial_num,1}.scan_path(1,2) = col_im_f ;
        
    if(save_logs)
        fprintf(fid, '%d, %d\n', row_im_f, col_im_f);
    end
    
    fixations_row = zeros(1,max_fix) ;
    fixations_col = zeros(1,max_fix) ;
    
    % --------------------------------------------------------------------
    % Srart the Trial
    % --------------------------------------------------------------------
    
    IOR_map = zeros(im_h,im_w );
    priority_map = zeros(im_h,im_w );
    fixation_map = zeros(im_h,im_w);
    RT_im_p = zeros(im_h,im_w);
    fixations_row(1)=row_im_f;
    fixations_col(1)=col_im_f;

    trial_end = 0 ;
    for fix = 2:max_fix  % starting from 2 since the first one is at the center 

        if (1) % % inhibit the first fixation but put(fix~=2) to not inhibit initial center fixation ...
            fixation_map(row_im_f,col_im_f) = 1 ;
            IOR_map = conv2(fixation_map,filt_IOR,'same') ;
        end

        % Applying Retina Transform
        if(Apply_Retina_Transform)
            RTransformed_im = Retina_Tran( input_im , row_im_f ,col_im_f ,  20);   %ceil(im_w/RETINA_PIXDEG)
        else
            RTransformed_im = input_im;
        end

        % Generate the priority/saliency map
        itti = ittikochmap_m( RTransformed_im , 0);  % the raw Itti-Koch map with NO final smoothing,
        %  I added the second argument to set the smoothing to zero
        sal_itti = itti.master_map_resized ;
        priority_map = sal_itti;
        
        % whether to smooth the priority map
        if(smooth_priority)
            priority_map = conv2( priority_map , fspecial('gaussian', [161 161], 80) ,'same') ;
        end
        
        % whether to only use the priority signal from the foregournd 
        if(use_foreground)
            im_foreground = (input_im(:,:,1)+input_im(:,:,2)+input_im(:,:,3)) >0 ;
            priority_map(~im_foreground)=0 ;
        end
        
        if(Apply_IOR)
            priority_map = priority_map - IOR_map ;
            priority_map( priority_map < 0 ) = 0 ; % RELU
        end

        
        switch Saccade_model
            case 1  % using Collicular Model
                % project to MASC and get the next fixation along with SC maps
                [ col_im_m , row_im_m , Vis_SC_frame , Moto_SC_frame , Moto_SC_frame_cross] = ...
                    MASC_core( priority_map , RETINA_PIXDEG , col_im_f , row_im_f, location_jitter) ; 
                
            case 2   % peak visiting Itti-Koch
                
                [s,I] = max(priority_map(:)) ;
                [row_im_m , col_im_m] = ind2sub([im_h,im_w],I) ;
                
                X = [row_im_f , col_im_f] ;
                Y = [row_im_m , col_im_m] ; 
                
                
                sac_amp = pdist([X;Y]) ;
                jitter_sigma = 0.06 * sac_amp ;
                jitter_limit = 2*jitter_sigma ;
                if(Reading && location_jitter)
                    jitter_pix = floor(normrnd(0,jitter_sigma)) ;
                    if  (abs(jitter_pix) > jitter_limit)
                        jitter_pix = jitter_limit * sign(jitter_pix) ;
                    end
                    col_im_m = col_im_m + floor(jitter_pix) ;
                end
                
                
                
            case 3   % Constant Saccade Model
                
                col_diff = floor(RETINA_PIXDEG * 1.98);
                col_im_m = col_im_f + col_diff ;

                if(col_im_m > right_limit)
                    col_im_m = right_limit;
                    trial_end = 1 ;
                end

                row_im_m = row_im_f;
                X = [row_im_f , col_im_f] ;
                Y = [row_im_m , col_im_m] ;
                sac_amp = pdist([X;Y]) ;

                if(Reading && location_jitter)
                    jitter_sigma = 0.06 * sac_amp ;
                    jitter_limit = 2*jitter_sigma ;
                    jitter_pix = floor(normrnd(0,jitter_sigma)) ;
                    if  (abs(jitter_pix) > jitter_limit)
                        jitter_pix = jitter_limit * sign(jitter_pix) ;
                    end
                    col_im_m = col_im_m + floor(jitter_pix) ;
                end
                
        end
        
        if(col_im_m < 1 )
            col_im_m = 1 ;
        end
        if(row_im_m < 1 )
            row_im_m = 1 ;
        end
        if(col_im_m > im_w )
            col_im_m = im_w ;
        end
        if(row_im_m > im_h )
            row_im_m = im_h ;
        end
        
        %update the current fixation
        row_im_f = double(row_im_m)  ;
        col_im_f = double(col_im_m)  ;
        
        fixations_row(fix)=row_im_m  ;
        fixations_col(fix)=col_im_m  ;

        if(save_logs)
            fprintf(fid, '%d, %d\n', row_im_f, col_im_f);
        end
        
        % if the fixation is too far off the sentence, terminte the trial 
        if(Reading == 1 &&  ( ( row_im_f > 520 || row_im_f < 430 ) ||  trial_end==1 ) ) 
            %fixations_col(fix)<= fixations_col(fix-1) )
            fix = fix - 1 ;
            break ;
        end
        
        
        Model_Data{trial_num,1}.scan_path(fix,1) = row_im_f ;
        Model_Data{trial_num,1}.scan_path(fix,2) = col_im_f ;
        
        if(save_output_maps)
            
            if (Saccade_model <= 2)
                new_image = sprintf('%s/%02d_RTransformed_im.png',output_dir,fix) ;    
                imwrite(RTransformed_im,new_image) ;
            
                new_image = sprintf('%s/%02d_priority_map.png',output_dir,fix) ;    
                imwrite(priority_map,new_image) ;
            end
            
            if (Saccade_model == 1)
                new_image = sprintf('%s/%02d_Vis_Coll.png',output_dir,fix) ;
                imwrite(Vis_SC_frame,new_image) ;

                new_image = sprintf('%s/%02d_Motor_Coll.png',output_dir,fix) ;    
                imwrite(Moto_SC_frame,new_image) ;

                new_image = sprintf('%s/%02d_Motor_Coll_Cross.png',output_dir,fix)  ;
                imwrite(Moto_SC_frame_cross,new_image) ;
            end
            
        end
        
        if(save_fixations)
            red = uint8([255 0 0]);
            light_red = uint8([255 166 166]);
            shapeInserter = vision.ShapeInserter('Fill',1 ,'FillColor','Custom','CustomFillColor',red,'Opacity',1);
            shapeInserter_l = vision.ShapeInserter('Fill',1 ,'FillColor','Custom','CustomFillColor',light_red,'Opacity',1);
            
%             Pts = int32([col_im_f-4 row_im_f-20 8 40 ; col_im_f-20 row_im_f-4 40 8]);
%             fixations_im = input_im ;
%             
%             fixations_im = step(shapeInserter, fixations_im, Pts);
%             new_image_name = sprintf('%s/%02d_Fixations_%03d_%03d.png',output_dir,fix,col_im_f , row_im_f) ;
%             imwrite(fixations_im,new_image_name)
            
            Pts_cf = int32([fixations_col(fix)-4 fixations_row(fix)-20 8 40 ; fixations_col(fix)-20 fixations_row(fix)-4 40 8]);
            fixations_im = input_im ;
            fixations_im = step(shapeInserter, fixations_im, Pts_cf);
            new_image_name = sprintf('%s/%02d_Fixations.png',output_dir,fix) ;
            imwrite(fixations_im,new_image_name)
            
            % points for the  previous fixation 
            Pts_pf = int32([fixations_col(fix-1)-4 fixations_row(fix-1)-20 8 40 ; fixations_col(fix-1)-20 fixations_row(fix-1)-4 40 8]);
            
            %new_image_name = sprintf('%s/%02d_Fixations_RT_%03d_%03d.png',output_dir,fix-1,fixations_col(fix-1) , fixations_row(fix-1)) ;
            
            if (fix == 2)
                RTransformed_im = step(shapeInserter, RTransformed_im, Pts_pf);
                new_image_name = sprintf('%s/%02d_Fixations_RT.png',output_dir,fix-1) ;
                imwrite(RTransformed_im,new_image_name)
                
            end

            % get the new RT imge
            RT_im = Retina_Tran( input_im , row_im_f ,col_im_f ,  20);             
            %Pts = int32([fixations_col(fix-1)-4 fixations_row(fix-1)-20 8 40 ; fixations_col(fix-1)-20 fixations_row(fix-1)-4 40 8]);
            RT_im = step(shapeInserter_l, RT_im, Pts_pf);
            RT_im = step(shapeInserter, RT_im, Pts_cf);
%             end
            
            new_image_name = sprintf('%s/%02d_Fixations_RT.png',output_dir,fix) ;
            imwrite(RT_im,new_image_name)

        end
    end

    if (show_scanpath)
        imshow(input_im)
        hold on
        for i=2:length(fixations_row)
            %line([fixations_col(i-1),fixations_col(i)], [fixations_row(i-1) , fixations_row(i)],'Color','c','LineWidth',.5);
            arrow([fixations_col(i-1),fixations_row(i-1)], [fixations_col(i) , fixations_row(i)],...
                'EdgeColor','r','FaceColor','r','LineWidth',1,'Length',12,'BaseAngle',40,'TipAngle',30)

        end
        hold off
        %new_image = sprintf('%s_Eye_movements.png',image_name ) ;
        new_image = sprintf('%s/scanpath.png',output_dir) ; 
        export_fig(gcf, new_image,'-q95')
    end
    
    if(save_Model_Data)
        Model_Data{trial_num,1}.Apply_IOR = Apply_IOR ;
        Model_Data{trial_num,1}.Apply_Retina_Transform = Apply_Retina_Transform ;
        Model_Data{trial_num,1}.IOR_size = IOR_size ;
        Model_Data{trial_num,1}.max_fix = max_fix;
        Model_Data{trial_num,1}.Init_row_im_f = Init_row_im_f ;
        Model_Data{trial_num,1}.Init_col_im_f = Init_col_im_f;
        Model_Data{trial_num,1}.RETINA_PIXDEG = RETINA_PIXDEG ;   % image pixels per visual angle  % default 30
        Model_Data{trial_num,1}.Saliency_model = Saliency_model;
        Model_Data{trial_num,1}.Saccade_model = Saccade_model ;   %   1:SC model   2:TAM averaging Method  3:Peak visiting
        Model_Data{trial_num,1}.num_fix = fix;
    end
    
    if(save_logs)
        fixations = [fixations_row',fixations_col'] ;
        fixations = array2table(fixations) ;
        fixations.Properties.VariableNames(1:2) = {'fix_row','fix_col'} ;
        writetable(fixations,fullfile(output_dir,'fixations.csv')) ;
        fclose(fid);
    end
    
end

if(save_Model_Data)
    save([results_dir, Model_output_name,'.mat'],'Model_Data')
end


%% save excel output
% Reading Utilities

if (save_Model_Data_excel)
    Reading_data = cell(length(Model_Data), 5);
    index = 0 ;
    for i=1:length(Model_Data)

        X = squeeze(Model_Data{i,1}.scan_path(:,2));
        Y = squeeze(Model_Data{i,1}.scan_path(:,1));
        %     if ( ~isempty(find(X==0)) )
        %         pause
        %     end
        for fix = 1:length(X)
            index = index + 1 ;
            Reading_data{index,1} = Model_Data{i,1}.filename ;
            Reading_data{index,2} = length(X) ;
            Reading_data{index,3} = fix ;
            Reading_data{index,4} = X(fix) ;
            Reading_data{index,5} = Y(fix);
        end
    end

    %filename = 'Reading_Model_61_20_ave_0_j_6_12.xlsx';
    xlswrite([results_dir, Model_output_name,'.xlsx'],Reading_data)

end









