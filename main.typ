#import "@preview/modern-g7-32:0.2.0": *
#import "@local/typst-bsuir-core:1.1.1": *
#import "@preview/zap:0.5.0"

#set text(font: "Times New Roman", size: 14pt)
#show math.equation: set text(font: "STIX Two Math", size: 14pt)

#show: gost.with(
  title-template: custom-title-template.from-module(toec-template),
  department: "Кафедра теоретических основ электротехники",
  work: (
    type: "Лабораторная работа",
    number: "4",
    subject: "Исследование резонанса в одиночных колебательных контурах",
    variant: "6",
  ),
  manager: (
    name: "Батюков С. В.",
  ),
  performer: (
    name: "Ермаков В. С.",
    group: "558301",
  ),
  footer: (city: "Минск", year: 2026),
  city: none,
  year: none,
  add-pagebreaks: false,
  text-size: 14pt,
)

#show: apply-toec-styling

// ==========================================
// БЛОК ВЫЧИСЛЕНИЙ (на печать не выводится)
// ==========================================
// Данные для последовательного контура (Бригада 6)
#let V_ser = (
  U: 3.5,      // По таблице 4.0 В, минус 0.5 В (условие преподавателя)
  rk: 29.0,    // Ом
  L: 224,      // мГн
  C: 7.47,     // мкФ
  brigade: 6
)

#let L1_H = V_ser.L * 1e-3
#let C1_F = V_ser.C * 1e-6
#let f0_ser = 1 / (2 * calc.pi * calc.sqrt(L1_H * C1_F))
#let rho_ser = calc.sqrt(L1_H / C1_F)
#let Q_ser = rho_ser / V_ser.rk

// Данные для параллельного контура (Бригада 6)
#let V_par = (
  U: 29.5,     // По таблице 30.0 В, минус 0.5 В (условие преподавателя)
  C: 6.47,     // мкФ
  L: 398,      // мГн
  rk: 41.0,    // Ом
  Rd1: 5.6,    // кОм
  Rd2: 9.0,    // кОм
  brigade: 6
)

#let L2_H = V_par.L * 1e-3
#let C2_F = V_par.C * 1e-6
#let f0_par = 1 / (2 * calc.pi * calc.sqrt(L2_H * C2_F))
#let rho_par = calc.sqrt(L2_H / C2_F)
#let R0_par = calc.pow(rho_par, 2) / V_par.rk
#let Q_par = rho_par / V_par.rk

#let Rd1_ohm = V_par.Rd1 * 1000
#let Rd2_ohm = V_par.Rd2 * 1000

#let Q1_pr = Q_par / (1 + (R0_par / Rd1_ohm))
#let Q2_pr = Q_par / (1 + (R0_par / Rd2_ohm))

#let Uk0_1 = V_par.U * (R0_par / (R0_par + Rd1_ohm))
#let Uk0_2 = V_par.U * (R0_par / (R0_par + Rd2_ohm))


// ==========================================
// НАЧАЛО ДОКУМЕНТА
// ==========================================

= Цель работы
Экспериментальное исследование частотных и резонансных характеристик последовательного контура, влияния активного сопротивления на вид резонансных кривых. Ознакомление с настройкой последовательного контура на резонанс с помощью емкости. Изучение частотных свойств параллельного колебательного контура, снятие амплитудно-частотных и фазочастотных характеристик.

= Расчет домашнего задания

== Последовательный колебательный контур

Исходные данные варианта #V_ser.brigade представлены в таблице @src-table-1.

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header(
      [Номер бригады], [$U_"ВХ"$, В], [$r_"k1"$, Ом], [$L_K$, мГн], [$C$, мкФ]
    ),
    [#V_ser.brigade], [#V_ser.U], [#V_ser.rk], [#V_ser.L], [#V_ser.C]
  ),
  caption: [Исходные данные для последовательного контура]
) <src-table-1>

Схема электрической цепи для последовательного соединения представлена на рисунке @src-circuit-1.

#lab-figure(
  above: -1em,
  circuit-better(scale-factor: 80%, {
    import zap: *
    node-better("1", (0, 4), visible: true)
    node-better("2", (12, 4), visible: true)
    node-better("3", (12, 0), visible: true)
    node-better("4", (0, 0), visible: true)

    open-branch-better("U_in", "1", "4", label: $dot(U)$, arrow-side: "left", arrow-dir: "down")

    wire("1", (2,4))
    current-arrow("I", (2,4), (4,4), arrow-label: $dot(I)$, arrow-side: "top", arrow-dir: "forward")
    resistor-better("rk", (4,4), (8,4), label: (content: $r_"k1"$, anchor: "bottom"))
    inductor-better("L", (8,4), "2", label: (content: $L_K$, anchor: "bottom"))

    capacitor-better("C", "2", "3", label: (content: $C$, anchor: "left"), arrow-label: $dot(U)_C$, arrow-side: "right", arrow-dir: "down")

    wire("3", "4")
  }),
  caption: [Схема для исследования последовательного колебательного контура]
) <src-circuit-1>

Определим резонансную частоту $f_0$, характеристическое сопротивление $rho$ и добротность контура $Q$.
#mathtype-mimic(spacing: 1em)[
  $ f_0 &= 1 / (2 pi sqrt(L_K C)) = 1 / (2 dot pi dot sqrt(#V_ser.L dot 10^(-3) dot #V_ser.C dot 10^(-6))) = #f0_ser " Гц"; $
  $ rho &= sqrt(L_K / C) = sqrt((#V_ser.L dot 10^(-3)) / (#V_ser.C dot 10^(-6))) = #rho_ser " Ом"; $
  $ Q &= rho / r_"k1" = #rho_ser / #V_ser.rk = #Q_ser. $
]

Зависимости тока в цепи и напряжений на элементах контура от частоты описываются уравнениями:
#mathtype-mimic(spacing: 1em)[
  $ I(f) &= U / sqrt(r_"k1"^2 + (2 pi f L_K - 1 / (2 pi f C))^2); $
  $ U_C (f) &= I(f) dot 1 / (2 pi f C); $
  $ U_L (f) &= I(f) dot 2 pi f L_K. $
]

Расчет и построение резонансных кривых тока $I(f)$, напряжения на емкости $U_C (f)$ и напряжения на идеальной индуктивности $U_L (f)$ представлены на рисунке @mathcad-series.

#figure(
  block(
    width: 100%, 
    height: 250pt, 
    fill: rgb(240, 240, 240), 
    stroke: 1pt + gray, 
    align(center + horizon)[Место для скриншота Mathcad (последовательный контур)]
  ),
  caption: [Резонансные кривые последовательного контура]
) <mathcad-series>

== Параллельный колебательный контур

Исходные данные для параллельного контура представлены в таблице @src-table-2.

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header(
      [Вариант], [$C$, мкФ], [$U$, В], [$R_("д"1)$, кОм], [$R_("д"2)$, кОм], [$L_2$, мГн], [$r_"k2"$, Ом]
    ),
    [#V_par.brigade], [#V_par.C], [#V_par.U], [#V_par.Rd1], [#V_par.Rd2], [#V_par.L], [#V_par.rk]
  ),
  caption: [Исходные данные для параллельного контура]
) <src-table-2>

Схема электрической цепи для исследования резонанса токов представлена на рисунке @src-circuit-2.

#lab-figure(
  above: -1em,
  circuit-better(scale-factor: 80%, {
    import zap: *
    node-better("T_SRC", (0, 6), visible: true)
    node-better("B_SRC", (0, 0), visible: true)
    
    // Узлы после резистора Rд
    node-better("T_TANK", (6, 6), visible: true)
    node-better("B_TANK", (6, 0), visible: true)

    // Узлы для правой ветви
    node-better("T_R", (10, 6), visible: false)
    node-better("M_R", (10, 3), visible: false)
    node-better("B_R", (10, 0), visible: false)

    // Источник напряжения слева
    open-branch-better("U_in", "T_SRC", "B_SRC", label: $dot(U)$, arrow-side: "left", arrow-dir: "down")

    // Rд на ВЕРХНЕМ проводе последовательно (как на рис. 3)
    resistor-better("Rd", "T_SRC", "T_TANK", label: (content: $R_"д"$, anchor: "bottom"))

    // Конденсатор C в первой параллельной ветви
    capacitor-better("C", "T_TANK", "B_TANK", label: (content: $C$, anchor: "left"))

    // L2 и rk2 во второй параллельной ветви
    wire("T_TANK", "T_R")
    inductor-better("L", "T_R", "M_R", label: (content: $L_2$, anchor: "left"))
    resistor-better("rk", "M_R", "B_R", label: (content: $r_"k2"$, anchor: "left"))

    // Возвратные провода
    wire("B_R", "B_TANK")
    wire("B_TANK", "B_SRC")
  }),
  caption: [Схема для исследования параллельного колебательного контура]
) <src-circuit-2>

Рассчитаем параметры параллельного контура: резонансную частоту $f_0$, характеристическое сопротивление $rho$, эквивалентное сопротивление при резонансе $R_0$ и собственную добротность $Q$.

#mathtype-mimic(spacing: 1em)[
  $ f_0 &= 1 / (2 pi sqrt(L_2 C)) = 1 / (2 dot pi dot sqrt(#V_par.L dot 10^(-3) dot #V_par.C dot 10^(-6))) = #f0_par " Гц"; $
  $ rho &= sqrt(L_2 / C) = sqrt((#V_par.L dot 10^(-3)) / (#V_par.C dot 10^(-6))) = #rho_par " Ом"; $
  $ R_0 &= rho^2 / r_"k2" = (#rho_par)^2 / #V_par.rk = #R0_par " Ом"; $
  $ Q &= rho / r_"k2" = #rho_par / #V_par.rk = #Q_par. $
]

#[
#set par(spacing: 0.8em)
При наличии источника с внутренним (добавочным) сопротивлением $R_"д"$, добротность контура $Q'$ ухудшается. Рассчитаем эквивалентную добротность и напряжение на контуре при резонансе $U_"k0"$ для двух значений сопротивления: $R_("д1") = #_fmt(V_par.Rd1)$ кОм и $R_("д2") = #_fmt(V_par.Rd2)$ кОм.

Для $R_("д1")$:
#v(0.5em)
#mathtype-mimic(spacing: 1em)[
  $ Q'_1 &= Q / (1 + R_0 / R_("д1")) = #Q_par / (1 + #R0_par / #Rd1_ohm) = #Q1_pr ; $
  $ U_("k0"_1) &= U dot R_0 / (R_0 + R_("д1")) = #V_par.U dot #R0_par / (#R0_par + #Rd1_ohm) = #Uk0_1 " В". $
]

#unbreakable[
Для $R_("д2")$:
#mathtype-mimic(spacing: 1em)[
  $ Q'_2 &= Q / (1 + R_0 / R_("д2")) = #Q_par / (1 + #R0_par / #Rd2_ohm) = #Q2_pr ; $
  $ U_("k0"_2) &= U dot R_0 / (R_0 + R_("д2")) = #V_par.U dot #R0_par / (#R0_par + #Rd2_ohm) = #Uk0_2 " В". $
]
]
#v(0.5em)
Амплитудно-частотная $U_k (f)$ и фазочастотная $phi (f)$ характеристики контура определяются выражениями:
#mathtype-mimic(spacing: 1em)[
  $ U_k (f) = U_"k0" / sqrt(1 + (Q' (f / f_0 - f_0 / f))^2); $
  $ phi (f) = - "arctg" (Q' (f / f_0 - f_0 / f)). $
]
]
Результаты представлены на рисунке @mathcad-parallel.

#figure(
  block(
    width: 100%, 
    height: 250pt, 
    fill: rgb(240, 240, 240), 
    stroke: 1pt + gray, 
    align(center + horizon)[Место для скриншота Mathcad (параллельный контур)]
  ),
  caption: [АЧХ и ФЧХ параллельного колебательного контура]
) <mathcad-parallel>

= Таблицы результатов измерений и расчетов

// ==========================================
// АВТОМАТИЧЕСКИЙ РАСЧЕТ ДЛЯ ПОСЛЕДОВАТЕЛЬНОГО КОНТУРА
// ==========================================
#let get_series_row(f) = {
  let w = 2 * calc.pi * f
  let XL = w * L1_H
  let XC = 1 / (w * C1_F)
  let Z = calc.sqrt(calc.pow(V_ser.rk, 2) + calc.pow(XL - XC, 2))
  let I = V_ser.U / Z
  let UC = I * XC
  let Uk = I * calc.sqrt(calc.pow(V_ser.rk, 2) + calc.pow(XL, 2))
  return (
    _fmt(I * 1000, digits: 3), [],
    _fmt(UC, digits: 3), [],
    _fmt(Uk, digits: 3), []
  )
}

#let f0_s_int = calc.round(f0_ser)
#let freqs_ser = (50, f0_s_int - 18, f0_s_int - 15, f0_s_int - 12, f0_s_int - 9, f0_s_int - 6, f0_s_int - 3, f0_ser, f0_s_int + 3, f0_s_int + 6, f0_s_int + 9, f0_s_int + 12, f0_s_int + 15, f0_s_int + 18, 200)
#let tbl_ser_content = ()

#for (i, f) in freqs_ser.enumerate() {
  if i == 0 { tbl_ser_content.push(table.cell(rowspan: 7)[До рез.]) }
  if i == 7 { tbl_ser_content.push(table.cell(rowspan: 1)[Рез.]) }
  if i == 8 { tbl_ser_content.push(table.cell(rowspan: 7)[После рез.]) }

  let f_fmt = if f == f0_ser { _fmt(f, digits: 3) } else { _fmt(f, digits: 0) }
  tbl_ser_content.push(f_fmt)

  let row_data = get_series_row(f)
  for item in row_data { tbl_ser_content.push(item) }
}

#unbreakable[
#figure(
  table(
    columns: (auto, auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header(
      table.cell(rowspan: 2)[Режим],
      table.cell(rowspan: 2)[$f$, Гц],
      table.cell(colspan: 2)[$I$, мА],
      table.cell(colspan: 2)[$U_C$, В],
      table.cell(colspan: 2)[$U_k$, В],
      [Расчет], [Опыт], [Расчет], [Опыт], [Расчет], [Опыт]
    ),
    ..tbl_ser_content
  ),
  caption: [Резонансные характеристики последовательного контура]
) <res-table-series>
]

// ==========================================
// АВТОМАТИЧЕСКИЙ РАСЧЕТ ДЛЯ ПАРАЛЛЕЛЬНОГО КОНТУРА
// ==========================================
#let get_parallel_row(f) = {
  let detuning = f / f0_par - f0_par / f
  let Uk1 = Uk0_1 / calc.sqrt(1 + calc.pow(Q1_pr * detuning, 2))
  let phi1 = - calc.atan(Q1_pr * detuning).deg()

  let Uk2 = Uk0_2 / calc.sqrt(1 + calc.pow(Q2_pr * detuning, 2))
  let phi2 = - calc.atan(Q2_pr * detuning).deg()

  return (
    _fmt(Uk1, digits: 3), [], _fmt(phi1, digits: 3), [],
    _fmt(Uk2, digits: 3), [], _fmt(phi2, digits: 3), []
  )
}

#let f0_p_int = calc.round(f0_par)
#let freqs_par = (50, f0_p_int - 18, f0_p_int - 15, f0_p_int - 12, f0_p_int - 9, f0_p_int - 6, f0_p_int - 3, f0_par, f0_p_int + 3, f0_p_int + 6, f0_p_int + 9, f0_p_int + 12, f0_p_int + 15, f0_p_int + 18, 180)
#let tbl_par_content = ()

#for (i, f) in freqs_par.enumerate() {
  if i == 0 { tbl_par_content.push(table.cell(rowspan: 7)[До рез.]) }
  if i == 7 { tbl_par_content.push(table.cell(rowspan: 1)[Рез.]) }
  if i == 8 { tbl_par_content.push(table.cell(rowspan: 7)[После рез.]) }

  let f_fmt = if f == f0_par { _fmt(f, digits: 3) } else { _fmt(f, digits: 0) }
  tbl_par_content.push(f_fmt)

  let row_data = get_parallel_row(f)
  for item in row_data { tbl_par_content.push(item) }
}

#unbreakable[
#figure(
  table(
    columns: (3em, 3em, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header(
      table.cell(rowspan: 3)[Режим],
      table.cell(rowspan: 3)[$f$, Гц],
      table.cell(colspan: 4)[При $R_"д1" = #_fmt(V_par.Rd1)$ кОм],
      table.cell(colspan: 4)[При $R_"д2" = #_fmt(V_par.Rd2)$ кОм],

      table.cell(colspan: 2)[$U_k$, В], table.cell(colspan: 2)[$phi$, град.],
      table.cell(colspan: 2)[$U_k$, В], table.cell(colspan: 2)[$phi$, град.],

      [Расч.], [Опыт], [Расч.], [Опыт], [Расч.], [Опыт], [Расч.], [Опыт]
    ),
    ..tbl_par_content
  ),
  caption: [Характеристики параллельного контура]
) <res-table-parallel>
]