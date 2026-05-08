%% =====================================================================
%  Набір сігмоїдних функцій нечіткої логіки
%  1) Основна одностороння (відкрита зліва / справа)
%  2) Додаткова двостороння (симетрична)
%  3) Додаткова несиметрична
%  =====================================================================
%  MATLAB Fuzzy Logic Toolbox: sigmf, smf, zmf, trapmf, pimf, dsigmf, psigmf
%  =====================================================================

clc; clear; close all;

x = linspace(-10, 10, 1000);   % загальна вісь аргументу

%% ─────────────────────────────────────────────────────────────────────
%  РИСУНОК 1 — Основна одностороння сігмоїда
%  sigmf(x, [a c]):  f(x) = 1 / (1 + exp(-a*(x-c)))
%  a > 0 → відкрита справа (зростаюча)
%  a < 0 → відкрита зліва  (спадаюча)
%% ─────────────────────────────────────────────────────────────────────
figure('Name','Одностороння сігмоїда','Color','white', ...
       'Position',[60 400 820 460]);

% --- відкрита СПРАВА (зростаюча) ---
subplot(1,2,1); hold on; grid on;
params_r = {[0.5, 0], [1.0, 0], [2.0, 0], [1.0, -3], [1.0, 3]};
labels_r = {'a=0.5, c=0','a=1.0, c=0','a=2.0, c=0', ...
            'a=1.0, c=-3','a=1.0, c=3'};
colors6 = {'#1a73e8','#e8290b','#1e8e3e','#f29900','#9334e6'};
for i = 1:numel(params_r)
    y = sigmf(x, params_r{i});
    plot(x, y, 'LineWidth', 2, 'Color', colors6{i}, ...
         'DisplayName', labels_r{i});
end
yline(0.5,'--k','LineWidth',0.8,'HandleVisibility','off');
xlabel('x'); ylabel('f(x)');
title('Відкрита справа  (a > 0)','FontWeight','normal');
legend('Location','southeast','FontSize',8);
ylim([-0.05, 1.05]); hold off;

% --- відкрита ЗЛІВА (спадаюча) ---
subplot(1,2,2); hold on; grid on;
params_l = {[-0.5, 0], [-1.0, 0], [-2.0, 0], [-1.0, -3], [-1.0, 3]};
labels_l = {'a=-0.5, c=0','a=-1.0, c=0','a=-2.0, c=0', ...
            'a=-1.0, c=-3','a=-1.0, c=3'};
for i = 1:numel(params_l)
    y = sigmf(x, params_l{i});
    plot(x, y, 'LineWidth', 2, 'Color', colors6{i}, ...
         'DisplayName', labels_l{i});
end
yline(0.5,'--k','LineWidth',0.8,'HandleVisibility','off');
xlabel('x'); ylabel('f(x)');
title('Відкрита зліва  (a < 0)','FontWeight','normal');
legend('Location','southwest','FontSize',8);
ylim([-0.05, 1.05]); hold off;

sgtitle('Основна одностороння сігмоїдна функція  —  sigmf(x,[a c])', ...
        'FontSize',12,'FontWeight','bold');

%% ─────────────────────────────────────────────────────────────────────
%  РИСУНОК 2 — Додаткова двостороння (симетрична) сігмоїда
%  Варіант A:  dsigmf — різниця двох sigmf
%              f = sigmf(x,[a1 c1]) - sigmf(x,[a2 c2])
%  Варіант B:  pimf  — π-функція (плавний трапецієподібний горб)
%  Варіант C:  smf / zmf — S-функція та Z-функція (пара)
%% ─────────────────────────────────────────────────────────────────────
figure('Name','Двостороння сігмоїда','Color','white', ...
       'Position',[60 -60 1100 440]);

% --- A: dsigmf ---
subplot(1,3,1); hold on; grid on;
combos = {[5,-4, 5, 4], [2,-5, 2, 5], [1,-3, 1, 3], [3,-2, 3, 2]};
lbls   = {'a=5,c=±4','a=2,c=±5','a=1,c=±3','a=3,c=±2'};
for i = 1:numel(combos)
    p = combos{i};
    y = dsigmf(x, p);
    plot(x, y, 'LineWidth', 2, 'Color', colors6{i}, ...
         'DisplayName', lbls{i});
end
xlabel('x'); ylabel('f(x)');
title('dsigmf — різниця сігмоїд','FontWeight','normal');
legend('Location','north','FontSize',8);
ylim([-0.1, 1.1]); hold off;

% --- B: pimf (π-функція) ---
subplot(1,3,2); hold on; grid on;
pi_params = {[-8,-3, 3, 8], [-6,-2, 2, 6], [-4,-1, 1, 4], [-3, 0, 2, 5]};
pi_lbls   = {'[-8,-3,3,8]','[-6,-2,2,6]','[-4,-1,1,4]','[-3,0,2,5]'};
for i = 1:numel(pi_params)
    y = pimf(x, pi_params{i});
    plot(x, y, 'LineWidth', 2, 'Color', colors6{i}, ...
         'DisplayName', pi_lbls{i});
end
xlabel('x'); ylabel('f(x)');
title('pimf — π-функція','FontWeight','normal');
legend('Location','north','FontSize',8);
ylim([-0.1, 1.1]); hold off;

% --- C: smf + zmf ---
subplot(1,3,3); hold on; grid on;
smf_params = {[-6,-2], [-5,-1], [-4, 0]};
zmf_params = {[ 2,  6], [ 1,  5], [ 0,  4]};
sm_lbls = {'smf [-6,-2]','smf [-5,-1]','smf [-4,0]'};
zm_lbls = {'zmf [2,6]',  'zmf [1,5]',  'zmf [0,4]'};
cs = {'#1a73e8','#e8290b','#1e8e3e'};
for i = 1:3
    plot(x, smf(x, smf_params{i}), '-',  'LineWidth',2,'Color',cs{i}, ...
         'DisplayName', sm_lbls{i});
    plot(x, zmf(x, zmf_params{i}), '--', 'LineWidth',2,'Color',cs{i}, ...
         'DisplayName', zm_lbls{i});
end
xlabel('x'); ylabel('f(x)');
title('smf (−−) і zmf (- -) як пара','FontWeight','normal');
legend('Location','east','FontSize',7.5);
ylim([-0.1, 1.1]); hold off;

sgtitle('Додаткова двостороння сігмоїдна функція', ...
        'FontSize',12,'FontWeight','bold');

%% ─────────────────────────────────────────────────────────────────────
%  РИСУНОК 3 — Додаткова несиметрична сігмоїда
%  Варіант A:  psigmf — добуток двох sigmf (несиметричне плато)
%  Варіант B:  trapmf з сігмоїдними схилами (через smf+zmf)
%  Варіант C:  Загострена несиметрична: різні a1 ≠ a2 у dsigmf
%% ─────────────────────────────────────────────────────────────────────
figure('Name','Несиметрична сігмоїда','Color','white', ...
       'Position',[960 400 1100 440]);

% --- A: psigmf (добуток) ---
subplot(1,3,1); hold on; grid on;
ps_combos = {[2,-4, -3, 4],  ...  % різні a → несиметрія
             [5,-3, -1, 2],  ...
             [1,-5, -2, 6],  ...
             [3,-2, -0.5, 4]};
ps_lbls = {'[2,-4,-3,4]','[5,-3,-1,2]','[1,-5,-2,6]','[3,-2,-0.5,4]'};
for i = 1:numel(ps_combos)
    y = psigmf(x, ps_combos{i});
    plot(x, y, 'LineWidth', 2, 'Color', colors6{i}, ...
         'DisplayName', ps_lbls{i});
end
xlabel('x'); ylabel('f(x)');
title('psigmf — добуток сігмоїд','FontWeight','normal');
legend('Location','north','FontSize',8);
ylim([-0.1, 1.1]); hold off;

% --- B: smf + zmf з різними крутизнами ---
subplot(1,3,2); hold on; grid on;
% Ліво-права пара з різними "шириною" підйому/спуску
asym_params = {[-8, -1,  2,  5], ...  % повільний підйом, швидкий спуск
               [-5, -2,  1,  3], ...
               [-6,  0,  3,  4], ...
               [-4, -3,  2,  8]};     % швидкий підйом, повільний спуск
asym_lbls = {'повіл. ↑, швид. ↓','середній','середній 2','швид. ↑, повіл. ↓'};
for i = 1:numel(asym_params)
    p  = asym_params{i};
    ys = smf(x, p(1:2));
    yz = zmf(x, p(3:4));
    y  = min(ys, yz);          % перетин smf і zmf = трапеція
    plot(x, y, 'LineWidth', 2, 'Color', colors6{i}, ...
         'DisplayName', asym_lbls{i});
end
xlabel('x'); ylabel('f(x)');
title('smf ∩ zmf — несиметричне плато','FontWeight','normal');
legend('Location','north','FontSize',8);
ylim([-0.1, 1.1]); hold off;

% --- C: dsigmf з різними крутизнами схилів ---
subplot(1,3,3); hold on; grid on;
ds_combos = {[1,-4,  5,  4],  ...  % пологий ліворуч, крутий праворуч
             [5,-4,  1,  4],  ...  % крутий ліворуч, пологий праворуч
             [2,-6,  8,  2],  ...  % дуже асиметричний
             [0.5,-3, 3,  5]};     % широкий пологий
ds_lbls = {'a1=1,a2=5','a1=5,a2=1','a1=2,a2=8','a1=0.5,a2=3'};
for i = 1:numel(ds_combos)
    y = dsigmf(x, ds_combos{i});
    plot(x, y, 'LineWidth', 2, 'Color', colors6{i}, ...
         'DisplayName', ds_lbls{i});
end
xlabel('x'); ylabel('f(x)');
title('dsigmf з різними a_1 ≠ a_2','FontWeight','normal');
legend('Location','north','FontSize',8);
ylim([-0.15, 1.1]); hold off;

sgtitle('Додаткова несиметрична сігмоїдна функція', ...
        'FontSize',12,'FontWeight','bold');

%% ─────────────────────────────────────────────────────────────────────
%  РИСУНОК 4 — Зведений огляд: по одному представнику кожного типу
%% ─────────────────────────────────────────────────────────────────────
figure('Name','Зведений огляд сігмоїд','Color','white', ...
       'Position',[960 -60 900 480]);
hold on; grid on;

y1 = sigmf(x,  [1.5,  0]);          % одностороння справа
y2 = sigmf(x,  [-1.5, 0]);          % одностороння зліва
y3 = dsigmf(x, [4,-4, 4, 4]);       % двостороння симетрична
y4 = pimf(x,   [-5,-2, 2, 5]);      % π-функція
y5 = psigmf(x, [2,-4, -1.5, 4]);    % несиметрична

plot(x, y1, '-',  'Color','#1a73e8', 'LineWidth',2.5, ...
     'DisplayName','Одностороння права  sigmf(a>0)');
plot(x, y2, '--', 'Color','#1a73e8', 'LineWidth',2.5, ...
     'DisplayName','Одностороння ліва   sigmf(a<0)');
plot(x, y3, '-',  'Color','#e8290b', 'LineWidth',2.5, ...
     'DisplayName','Двостороння симетрична  dsigmf');
plot(x, y4, '-',  'Color','#1e8e3e', 'LineWidth',2.5, ...
     'DisplayName','Двостороння π-функція   pimf');
plot(x, y5, '-',  'Color','#f29900', 'LineWidth',2.5, ...
     'DisplayName','Несиметрична            psigmf');

xlabel('x'); ylabel('f(x)');
title('Зведений огляд: основні типи сігмоїдних функцій', ...
      'FontSize',12,'FontWeight','bold');
legend('Location','east','FontSize',10);
ylim([-0.1, 1.15]);
hold off;

fprintf('=== Побудовано 4 фігури ===\n');
fprintf('  Рис. 1 — Одностороння сігмоїда (sigmf)\n');
fprintf('  Рис. 2 — Двостороння симетрична (dsigmf, pimf, smf+zmf)\n');
fprintf('  Рис. 3 — Несиметрична (psigmf, smf∩zmf, dsigmf a1≠a2)\n');
fprintf('  Рис. 4 — Зведений огляд\n');
