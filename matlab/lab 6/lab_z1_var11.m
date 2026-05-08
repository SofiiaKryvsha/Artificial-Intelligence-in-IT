%% ============================================================
%  Лабораторна робота №1 — Варіант 11
%  Функція: z(x,y) = cos(y) - x/2
%  Запуск: >> lab_z1_var11
%% ============================================================
clear; clc; close all;

%% ── Параметри ───────────────────────────────────────────────
f     = @(x,y) cos(y) - x/2;
N_IN  = 6;
N_OUT = 9;
X_MIN = 0; X_MAX = pi/2;
Y_MIN = 0; Y_MAX = pi/2;
Z_MIN = -0.8; Z_MAX = 1.05;   % діапазон cos(y)-x/2 при x,y in [0,pi/2]

x_centers = linspace(X_MIN, X_MAX, N_IN);
y_centers = linspace(Y_MIN, Y_MAX, N_IN);
z_centers = linspace(Z_MIN, Z_MAX, N_OUT);

%% ── Таблиця значень ─────────────────────────────────────────
fprintf('\n=== z(x,y)=cos(y)-x/2  [ значення у точках МФ ] ===\n');
fprintf('%10s','');
for j=1:N_IN, fprintf('%9.3f', y_centers(j)); end; fprintf('\n');
Z_tbl = zeros(N_IN);
for i=1:N_IN
    fprintf('%10.3f', x_centers(i));
    for j=1:N_IN
        Z_tbl(i,j) = f(x_centers(i), y_centers(j));
        fprintf('%9.3f', Z_tbl(i,j));
    end; fprintf('\n');
end

%% ── Таблиця правил ──────────────────────────────────────────
Rule_tbl = zeros(N_IN);
fprintf('\n=== Таблиця правил (індекс вихідної МФ 1..%d) ===\n',N_OUT);
fprintf('%10s','');
for j=1:N_IN, fprintf('%6s',['my',num2str(j)]); end; fprintf('\n');
for i=1:N_IN
    fprintf('%10s',['mx',num2str(i)]);
    for j=1:N_IN
        [~,idx] = min(abs(z_centers - Z_tbl(i,j)));
        Rule_tbl(i,j) = idx;
        fprintf('%6s',['mf',num2str(idx)]);
    end; fprintf('\n');
end

%% ── Функція побудови FIS ────────────────────────────────────
function fis = make_fis(mf_type, rule_tbl, ...
        x_min,x_max, y_min,y_max, z_min,z_max, n_in, n_out)

    fis = mamfis('Name', mf_type);
    inputs  = {{'x',x_min,x_max,'mx'}, {'y',y_min,y_max,'my'}};
    steps   = [(x_max-x_min)/(n_in-1), (y_max-y_min)/(n_in-1)];

    for inp = 1:2
        nm  = inputs{inp}{1};
        lo  = inputs{inp}{2};
        hi  = inputs{inp}{3};
        pfx = inputs{inp}{4};
        st  = steps(inp);
        fis = addInput(fis,[lo hi],'Name',nm);
        for k=1:n_in
            c = lo+(k-1)*st;
            switch mf_type
              case 'gaussmf'
                fis = addMF(fis,nm,'gaussmf',[st*0.45 c],'Name',[pfx,num2str(k)]);
              case 'trimf'
                fis = addMF(fis,nm,'trimf',[max(lo,c-st) c min(hi,c+st)],...
                            'Name',[pfx,num2str(k)]);
              case 'trapmf'
                fis = addMF(fis,nm,'trapmf',...
                    [max(lo,c-st*.95) max(lo,c-st*.35) ...
                     min(hi,c+st*.35) min(hi,c+st*.95)],...
                    'Name',[pfx,num2str(k)]);
            end
        end
    end

    fis = addOutput(fis,[z_min z_max],'Name','z');
    st_z = (z_max-z_min)/(n_out-1);
    for k=1:n_out
        c = z_min+(k-1)*st_z;
        switch mf_type
          case 'gaussmf'
            fis = addMF(fis,'z','gaussmf',[st_z*0.4 c],'Name',['mf',num2str(k)]);
          case 'trimf'
            fis = addMF(fis,'z','trimf',[max(z_min,c-st_z) c min(z_max,c+st_z)],...
                        'Name',['mf',num2str(k)]);
          case 'trapmf'
            fis = addMF(fis,'z','trapmf',...
                [max(z_min,c-st_z*.95) max(z_min,c-st_z*.35) ...
                 min(z_max,c+st_z*.35) min(z_max,c+st_z*.95)],...
                'Name',['mf',num2str(k)]);
        end
    end

    rules = [];
    for i=1:n_in, for j=1:n_in
        rules(end+1,:) = [i j rule_tbl(i,j) 1 1]; %#ok<AGROW>
    end; end
    fis = addRule(fis, rules);
end

%% ── Сітка для оцінки похибки ────────────────────────────────
N_eval  = 10;
xs_eval = linspace(X_MIN+0.05, X_MAX-0.05, N_eval);
ys_eval = linspace(Y_MIN+0.05, Y_MAX-0.05, N_eval);
[Xe,Ye] = meshgrid(xs_eval, ys_eval);
Ze_true = f(Xe, Ye);

mf_types  = {'gaussmf','trimf','trapmf'};
mf_labels = {'Гаусова','Трикутна','Трапецієподібна'};
err_full  = zeros(1,3);
err_diag  = zeros(1,3);

%% ── Цикл по типах МФ ────────────────────────────────────────
for m = 1:3
    mft = mf_types{m};

    % Повна база (36 правил)
    fis36 = make_fis(mft, Rule_tbl, ...
        X_MIN,X_MAX, Y_MIN,Y_MAX, Z_MIN,Z_MAX, N_IN, N_OUT);
    Ze_pred = zeros(size(Xe));
    for ii=1:numel(Xe)
        Ze_pred(ii) = evalfis(fis36,[Xe(ii) Ye(ii)]);
    end
    eps36 = abs(Ze_true-Ze_pred)./(abs(Ze_true)+1)*100;
    err_full(m) = mean(eps36(:));

    % Діагональна база (6 правил)
    Rule_diag = ones(N_IN)*Rule_tbl(1,1);
    for k=1:N_IN, Rule_diag(k,k)=Rule_tbl(k,k); end
    for i=1:N_IN, for j=1:N_IN
        if i~=j
            [~,ni]=min(abs((1:N_IN)-mean([i j])));
            Rule_diag(i,j)=Rule_tbl(ni,ni);
        end
    end; end
    fis6 = make_fis(mft, Rule_diag, ...
        X_MIN,X_MAX, Y_MIN,Y_MAX, Z_MIN,Z_MAX, N_IN, N_OUT);
    Ze_diag = zeros(size(Xe));
    for ii=1:numel(Xe)
        Ze_diag(ii) = evalfis(fis6,[Xe(ii) Ye(ii)]);
    end
    epsd = abs(Ze_true-Ze_diag)./(abs(Ze_true)+1)*100;
    err_diag(m) = mean(epsd(:));

    fprintf('\n[%s]  Повна: %.2f%%   Діагональ: %.2f%%\n',...
        mf_labels{m}, err_full(m), err_diag(m));
    if m==1, assignin('base','fis_z_gauss',fis36); end
end

%% ── Графік 1: 3D еталонна поверхня ─────────────────────────
figure('Name','z — Еталон','Color','w','Position',[50 50 600 470]);
[Xg,Yg] = meshgrid(linspace(X_MIN,X_MAX,50), linspace(Y_MIN,Y_MAX,50));
surf(Xg,Yg,f(Xg,Yg),'EdgeColor','none'); colormap plasma; colorbar;
xlabel('x'); ylabel('y'); zlabel('z'); grid on;
title('Еталонна поверхня  z = cos(y) - x/2','FontSize',12);

%% ── Графік 2: heatmap таблиці правил ───────────────────────
figure('Name','z — Таблиця правил','Color','w','Position',[680 50 500 420]);
imagesc(Rule_tbl); colormap(gca,parula); colorbar;
set(gca,'XTickLabel',arrayfun(@(k)['mx',num2str(k)],1:N_IN,'UniformOutput',false),...
        'YTickLabel',arrayfun(@(k)['my',num2str(k)],1:N_IN,'UniformOutput',false),...
        'FontSize',10);
xlabel('Вхід x'); ylabel('Вхід y');
title('Таблиця правил — z (індекс вихідної МФ)');
for i=1:N_IN, for j=1:N_IN
    text(j,i,['mf',num2str(Rule_tbl(i,j))],...
         'HorizontalAlignment','center','FontSize',9,'Color','k');
end; end
hold on;
for k=1:N_IN
    rectangle('Position',[k-.5 k-.5 1 1],'EdgeColor','r','LineWidth',2.5);
end
legend('Діагональні правила','Location','NorthWest');

%% ── Графік 3: МФ входів ─────────────────────────────────────
figure('Name','z — МФ','Color','w','Position',[50 560 900 300]);
univ = linspace(X_MIN,X_MAX,500);
step = (X_MAX-X_MIN)/(N_IN-1);
names3 = {'Гаусова','Трикутна','Трапецієподібна'};
mf_fns = {@(u,c) gaussmf(u,[step*.45 c]), ...
           @(u,c) trimf(u,[max(X_MIN,c-step) c min(X_MAX,c+step)]), ...
           @(u,c) trapmf(u,[max(X_MIN,c-step*.95) max(X_MIN,c-step*.35) ...
                             min(X_MAX,c+step*.35) min(X_MAX,c+step*.95)])};
for s=1:3
    subplot(1,3,s); hold on;
    for k=1:N_IN
        plot(univ, mf_fns{s}(univ, x_centers(k)), 'LineWidth',1.7);
    end
    title(names3{s}); xlabel('x'); ylabel('\mu'); grid on; ylim([0 1.15]);
end
sgtitle('МФ входу x  —  z(x,y) = cos(y) - x/2');

%% ── Графік 4: порівняння похибок ────────────────────────────
figure('Name','z — Похибки','Color','w','Position',[680 520 640 400]);
xb=1:3; wb=0.35;
b1=bar(xb-wb/2, err_full, wb,'FaceColor','flat');
b1.CData=[0.18 0.63 0.35; 0.85 0.25 0.25; 0.22 0.48 0.78];
hold on;
b2=bar(xb+wb/2, err_diag, wb,'FaceColor','flat','FaceAlpha',0.5);
b2.CData=b1.CData;
set(gca,'XTickLabel',mf_labels,'FontSize',11);
legend({'36 правил','6 правил (діагональ)'},'Location','NorthWest');
ylabel('Середня похибка \epsilon, %');
title('z = cos(y) - x/2  — Порівняння похибок');
grid on;
for k=1:3
    text(k-wb/2,err_full(k)+.15,sprintf('%.1f%%',err_full(k)),...
         'HorizontalAlignment','center','FontSize',9,'FontWeight','bold');
    text(k+wb/2,err_diag(k)+.15,sprintf('%.1f%%',err_diag(k)),...
         'HorizontalAlignment','center','FontSize',9,'Color',[.5 0 0]);
end

%% ── Висновки ────────────────────────────────────────────────
[~,bi]=min(err_full); [~,wi]=max(err_full);
fprintf('\n╔══════════════════════════════════════════════════════════╗\n');
fprintf('║   ВИСНОВКИ  z(x,y) = cos(y) - x/2                      ║\n');
fprintf('╠══════════════════════════════════════════════════════════╣\n');
fprintf('║ П.1  FIS Mamdani: 2 входи × %d МФ, 1 вихід × %d МФ       ║\n',N_IN,N_OUT);
fprintf('║      36 правил (Mamdani, дефазифікація — центроїд).    ║\n');
fprintf('╠══════════════════════════════════════════════════════════╣\n');
fprintf('║ П.2  Найкраща МФ  : %-16s (%.2f%%)         ║\n',mf_labels{bi},err_full(bi));
fprintf('║      Найгірша МФ  : %-16s (%.2f%%)         ║\n',mf_labels{wi},err_full(wi));
fprintf('╠══════════════════════════════════════════════════════════╣\n');
fprintf('║ П.3  Діагональ (6): похибка зростає в %.1fx             ║\n',mean(err_diag./err_full));
fprintf('║      Повна база є необхідною умовою точності.           ║\n');
fprintf('╠══════════════════════════════════════════════════════════╣\n');
fprintf('║ П.4  Оптимум: %s МФ + 36 правил.          ║\n',mf_labels{bi});
fprintf('╚══════════════════════════════════════════════════════════╝\n');
