%% =====================================================================
%  Кластеризація методами нечіткої логіки (Fuzzy C-Means)
%  Командний рядок + побудова графіків
%  =====================================================================
%  MATLAB Toolbox: Fuzzy Logic Toolbox
%  Функція: fcm() — Fuzzy C-Means clustering
%  =====================================================================

clc; clear; close all;

%% --- 1. Генерація або завантаження вхідних даних -------------------
rng(42);   % для відтворюваності результатів

% Три синтетичні кластери у 2D-просторі
group1 = [randn(50,1)*0.5 + 2,  randn(50,1)*0.5 + 2 ];
group2 = [randn(50,1)*0.5 + 6,  randn(50,1)*0.5 + 5 ];
group3 = [randn(50,1)*0.5 + 4,  randn(50,1)*0.5 + 8 ];

data = [group1; group2; group3];   % матриця даних N×2

%% --- 2. Параметри алгоритму FCM ------------------------------------
numClusters  = 3;      % кількість кластерів
options      = [2.0,   ... % m — показник нечіткості (m > 1, зазвичай 2)
                100,   ... % maxIter — максимальна кількість ітерацій
                1e-5,  ... % minImprovement — поріг зупинки
                1];        % displayInfo — 1 = виводити прогрес у консоль

%% --- 3. Виклик fcm() з ДОДАТКОВИМ набором параметрів ---------------
%    [centers, U, objFun] = fcm(data, numClusters, options)
%    centers  — матриця центрів кластерів (numClusters × numFeatures)
%    U        — матриця нечіткої приналежності (numClusters × N)
%    objFun   — вектор значень цільової функції на кожній ітерації

fprintf('=== Запуск FCM кластеризації ===\n');
fprintf('Кількість кластерів : %d\n', numClusters);
fprintf('Показник нечіткості : %.1f\n', options(1));
fprintf('Макс. ітерацій      : %d\n', options(2));
fprintf('Поріг зупинки       : %g\n\n', options(3));

[centers, U, objFun] = fcm(data, numClusters, options);

%% --- 4. Визначення «жорстких» кластерів для візуалізації -----------
[~, clusterIdx] = max(U);   % індекс кластера з макс. приналежністю

%% --- 5. Вивід центрів кластерів у консоль --------------------------
fprintf('\n=== Центри кластерів ===\n');
fprintf('%-10s %-12s %-12s\n', 'Кластер', 'X (ознака 1)', 'Y (ознака 2)');
fprintf('%s\n', repmat('-',1,36));
for k = 1:numClusters
    fprintf('%-10d %-12.4f %-12.4f\n', k, centers(k,1), centers(k,2));
end

fprintf('\nЦільова функція (остання ітерація): %.6f\n', objFun(end));
fprintf('Всього ітерацій виконано         : %d\n\n', numel(objFun));

%% --- 6. Графіки -------------------------------------------------------
colors = {'#1a73e8','#e8290b','#1e8e3e'};   % синій, червоний, зелений
markers = {'o','s','^'};

figure('Name','FCM — Результати кластеризації','NumberTitle','off', ...
       'Color','white','Position',[100 100 1200 500]);

% ---- 6a. Розподіл точок за кластерами ----
subplot(1,2,1); hold on; grid on;
for k = 1:numClusters
    idx = (clusterIdx == k);
    scatter(data(idx,1), data(idx,2), 40, ...
            'Marker', markers{k}, ...
            'MarkerFaceColor', colors{k}, ...
            'MarkerEdgeColor', 'none', ...
            'DisplayName', sprintf('Кластер %d', k));
end
% Нанесення центрів
scatter(centers(:,1), centers(:,2), 200, 'k', 'p', ...
        'MarkerFaceColor','yellow', 'MarkerEdgeColor','k', ...
        'LineWidth',1.5, 'DisplayName','Центри кластерів');

% Кола (радіус = середньозважене відхилення) навколо центрів
theta = linspace(0, 2*pi, 200);
for k = 1:numClusters
    idx   = (clusterIdx == k);
    r     = mean(sqrt(sum((data(idx,:) - centers(k,:)).^2, 2)));
    xc    = centers(k,1) + r*cos(theta);
    yc    = centers(k,2) + r*sin(theta);
    plot(xc, yc, '--', 'Color', colors{k}, 'LineWidth',1.2, ...
         'HandleVisibility','off');
end

xlabel('Ознака 1'); ylabel('Ознака 2');
title('Fuzzy C-Means: розподіл за кластерами');
legend('Location','best','FontSize',9);
hold off;

% ---- 6b. Зміна цільової функції (збіжність) ----
subplot(1,2,2); hold on; grid on;
iters = 1:numel(objFun);
area(iters, objFun, 'FaceColor','#d2e3fc', 'EdgeColor','none');
plot(iters, objFun, '-o', ...
     'Color','#1a73e8', 'LineWidth',2, ...
     'MarkerFaceColor','white', 'MarkerEdgeColor','#1a73e8', ...
     'MarkerSize',5);

% Позначити мінімум
[minVal, minIt] = min(objFun);
plot(minIt, minVal, 'r*', 'MarkerSize',14, 'LineWidth',2, ...
     'DisplayName', sprintf('Мінімум: %.4f (ітерація %d)', minVal, minIt));

xlabel('Ітерація'); ylabel('Значення цільової функції J');
title('Збіжність алгоритму FCM (цільова функція)');
legend('Location','best','FontSize',9);
hold off;

sgtitle('Кластеризація методами нечіткої логіки — Fuzzy C-Means', ...
        'FontSize',13,'FontWeight','bold');

%% --- 7. Матриця приналежностей (перші 10 точок) --------------------
fprintf('\n=== Матриця нечіткої приналежності U (перші 10 точок) ===\n');
header = sprintf('%-8s', 'Точка');
for k = 1:numClusters
    header = [header, sprintf('  Кластер%d', k)]; %#ok<AGROW>
end
fprintf('%s\n%s\n', header, repmat('-',1,8+11*numClusters));
for i = 1:10
    row = sprintf('%-8d', i);
    for k = 1:numClusters
        row = [row, sprintf('  %9.4f', U(k,i))]; %#ok<AGROW>
    end
    fprintf('%s\n', row);
end

fprintf('\n=== Готово! ===\n');
