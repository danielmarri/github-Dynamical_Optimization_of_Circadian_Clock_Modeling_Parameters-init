function flag = AMIGO_gen_obs_sens(inputs,results)
% AMIGO_gen_obs_sens: Generates necessary file and functions to compute the
% observables' sensitivity in general. The normal observation function is
% faster and can be used if the observables are linear functions of the
% states. 
%
%******************************************************************************
% AMIGO2: dynamic modeling, optimization and control of biological systems    % 
% Code development:     Eva Balsa-Canto                                       %
% Address:              Process Engineering Group, IIM-CSIC                   %
%                       C/Eduardo Cabello 6, 36208, Vigo-Spain                %
% e-mail:               ebalsa@iim.csic.es                                    %
% Copyright:            CSIC, Spanish National Research Council               %
%******************************************************************************
%
%*****************************************************************************%
%                                                                             %
%  AMIGO_gen_obs_sens: Generates a matlab file to compute provided observables' sensitivities     %
%                 from the states and state sensitivities                                           %
%                                                                             %
%               Paths will be added at any AMIGO session so as user does not  %
%               need to modify the MATLAB path                                %
%               Note that folders keeping problem results will be created     %
%               under the Results folder (unless otherwise specified)         %
%               All problem related files (inputs, outputs and intermediate   %
%               files) will be kept in such folder.                           %
%*****************************************************************************%
flag = 0;
if ~license('test','symbolic_toolbox')
    fprintf('---> WARNING: License for the MATLAB Symbolic Toolbox is not detected. Sensitivities for nonlinear observables could not be generated.\n')
    flag = -1;
    return;
end


%% generate the partial derivatives dhdp dhdx
for iexp = 1:inputs.exps.n_exp
    [dhdx{iexp} dhdp{iexp}] = AMIGO_generateObsSensRHS(inputs.model.st_names,inputs.model.par_names,inputs.exps.obs{iexp});
end



%% write the file main function
inputs.pathd.obs_function = strcat('AMIGO_gen_obs_',inputs.pathd.short_name);
inputs.pathd.obs_sens_function = strcat('AMIGO_gen_obs_sens_',inputs.pathd.short_name);
inputs.pathd.obs_sens_file=strcat(inputs.pathd.AMIGO_path,filesep,inputs.pathd.problem_folder_path,filesep,inputs.pathd.obs_sens_function,'.m');
fid=fopen(inputs.pathd.obs_sens_file,'w');
% fid = 1;


fprintf(fid,'function dydp=%s(x,dxdp,inputs,p,exp)\n',inputs.pathd.obs_sens_function);
fprintf(fid,'%%function automatically generated by AMIGO_gen_obs_sens\n');
fprintf(fid,'%% calculates the sensitivities of the observables from state sensitivities\n');
fprintf(fid,'\n%% states:\n');
for i=1:inputs.model.n_st
    fprintf(fid,'%s=x(:,%u);\n',inputs.model.st_names(i,:),i);
    %fprintf(fid,'d%s=dxdp(:,%u,:);\n',inputs.model.st_names(i,:),i);
end
fprintf(fid,'\n%% parameters:\n');
for i=1:inputs.model.n_par
    fprintf(fid,'%s=p(%u);\n',inputs.model.par_names(i,:),i);
end
%fprintf(fid,'\n%% observables:\n');
%obsfunc=results.pathd.obs_function;
%fprintf(fid,'obs=feval(%s,x,inputs,p,exp);\n',obsfunc);


fprintf(fid,'\nswitch exp\n');

for iexp=1:inputs.exps.n_exp
    fprintf(fid,'\tcase %d\n',iexp);
    fprintf(fid,'\t\tdydp = zeros(%u,%u,%u);\n',inputs.exps.n_obs{iexp},inputs.model.n_par,inputs.exps.n_s{iexp});
    fprintf(fid,'\t\tdhdx = fdhdx(%d);\n',iexp);
    fprintf(fid,'\t\tdhdp = fdhdp(%d);\n',iexp);
    fprintf(fid,'\t\tfor ti = 1:%u\n',inputs.exps.n_s{iexp});
    fprintf(fid,'\t\t\t dydp(:,:,ti) = dhdx(:,:,ti)*dxdp(:,:,ti) + dhdp(:,:,ti);\n');
    fprintf(fid,'\t\tend\n');
    
end
fprintf(fid,'end %% end of switch/case exp\n\n');


fprintf(fid,'%%%%%%%%   HELPER FUNCTIONS %%%%%%%%\n\n');
%% write helper functions: dhdx
fprintf(fid,'\tfunction Hx = fdhdx(exp)\n');%y,par,
fprintf(fid,'\t%% Calucates the partial derivative of the observaton function wrt the states\n');
% fprintf(fid,'%% states:\n');
% for i=1:inputs.model.n_st
%     fprintf(fid,'\t%s=y(:,%u);\n',inputs.model.st_names(i,:),i);
% end
% fprintf(fid,'%% parameters:\n');
% for i=1:inputs.model.n_par
%     fprintf(fid,'\t%s=par(%u);\n',inputs.model.par_names(i,:),i);
% end
% fprintf(fid,'%% observables:\n');
% obsfunc=results.pathd.obs_function;
% fprintf(fid,'obs=feval(%s,y,inputs,par,exp);\n\n',obsfunc);


fprintf(fid,'\t\tswitch exp\n');
for iexp=1:inputs.exps.n_exp
    fprintf(fid,'\t\tcase %d\n',iexp);
    %     for iobs=1:inputs.exps.n_obs{iexp}
    %         fprintf(fid,'\t\t%s=obs(:,%u);\n',inputs.exps.obs_names{iexp}(iobs,:),iobs);
    %     end
    fprintf(fid,'\t\t\t\tHx = zeros(%u,%u,%u);\n',inputs.exps.n_obs{iexp}, inputs.model.n_st,inputs.exps.n_s{iexp});
    for iobs = 1:inputs.exps.n_obs{iexp}
        for ist = 1:inputs.model.n_st;
            if dhdx{iexp}(iobs,ist) ~= 0
                tmp = strrep(char(dhdx{iexp}(iobs,ist)),'/','./');
                tmp = strrep(tmp,'*','.*');
                tmp = strrep(tmp,'^','.^');
                fprintf(fid,'\t\t\t\tHx(%u,%u,:) = %s;\n',iobs,ist,tmp);
            end
        end
    end
    
end
fprintf(fid,'\t\tend  %% end of switch\n');
fprintf(fid,'\tend %% end of fdhdp\n\n');


%% write helper functions: dhdp
fprintf(fid,'\tfunction Hp = fdhdp(exp)\n');%y,par,
fprintf(fid,'\t%%Calculates the partial derivative of the objective wrt the parameters.\n');
% fprintf(fid,'%% states:\n');
% for i=1:inputs.model.n_st
%     fprintf(fid,'\t%s=y(:,%u);\n',inputs.model.st_names(i,:),i);
% end
% fprintf(fid,'%% parameters:\n');
% for i=1:inputs.model.n_par
%     fprintf(fid,'\t%s=par(%u);\n',inputs.model.par_names(i,:),i);
% end
% fprintf(fid,'%% observables:\n');
% obsfunc=results.pathd.obs_function;
% fprintf(fid,'obs=feval(%s,y,inputs,par,exp);\n\n',obsfunc);
%

fprintf(fid,'\t\tswitch exp\n');
for iexp=1:inputs.exps.n_exp
    fprintf(fid,'\t\t\tcase %d\n',iexp);
    %     for iobs=1:inputs.exps.n_obs{iexp}
    %         fprintf(fid,'\t\t%s=obs(:,%u);\n',inputs.exps.obs_names{iexp}(iobs,:),iobs);
    %     end
    fprintf(fid,'\t\t\t\tHp = zeros(%u,%u,%u);\n',inputs.exps.n_obs{iexp}, inputs.model.n_par,inputs.exps.n_s{iexp});
    for iobs = 1:inputs.exps.n_obs{iexp}
        for ipar = 1:inputs.model.n_par;
            if dhdp{iexp}(iobs,ipar) ~= 0
                tmp = strrep(char(dhdp{iexp}(iobs,ipar)),'/','./');
                tmp = strrep(tmp,'*','.*');
                tmp = strrep(tmp,'^','.^');
                fprintf(fid,'\t\t\t\tHp(%u,%u,:) = %s;\n',iobs,ipar,tmp);
            end
        end
    end
end
fprintf(fid,'\t\tend  %% end of switch\n');
fprintf(fid,'\tend %% end of fdhdp\n\n');
fprintf(fid,'end %% end of main function\n\n');
fclose(fid);
end

