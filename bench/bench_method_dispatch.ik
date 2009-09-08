use("benchmark")

obj = Origin mimic

obj m = method(nil)

obj control = method(
  1000 times(nil)
)

;; calls m() 1_000_000 times
obj bench_method_dispatch = method(
  1000 times(
    ;; 20 columns
    ;; 10 rows
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.

    ;; 20 columns
    ;; 10 rows
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.

    ;; 20 columns
    ;; 10 rows
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.

    ;; 20 columns
    ;; 10 rows
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.

    ;; 20 columns
    ;; 10 rows
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
    m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m. m.
  )
)

control = method(obj control)
bench_method_dispatch = method(obj bench_method_dispatch)

Benchmark report(1, 1, control)
Benchmark report(bench_method_dispatch)
