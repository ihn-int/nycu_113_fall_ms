# Trace code

## main

`main()` 依序進行：
1. 讀取模型和圖片（時間被記錄下來）。
2. 建立與初始化 cnn （命名為 `nn`）。建立 cnn 的控制器 `ctrl` 。
3. 加入 cnn 的 layer 。
4. 開始測試 cnn 的準確率（時間被記錄下來）。
    - 調用 `cnn_evaluate()` 。
5. 釋放動態調用的資源。

## conv_3d

```c
for (uint64_t inc = 0; inc < in_.depth_; inc++) {
```
`convolutional_layer` 的 `entry` 會具有一個 `in_` 變數，這個變數是此 layer 的寬高深。根據 cnn 的每一個深度（`depth_`）進行遍歷，計算每一層寬高的資料。

```c
        const float_t *pw = &W[get_index(&weight_, 0, 0, in_.depth_ * o + inc)];
```
取得 cnn layer 的 `W` 資料的位址。 `W` 是 single pointer ，因此需要再取一次位址。 **`pw` 的值被設定好了。**

```c
        // Convert repeatedly calculated numbers to constants.
        float_t * ppi = &in[get_index(&in_padded_, 0, 0, inc)];
        uint64_t idx = 0;
        const uint64_t inner_loop_iter = weight_.height_ * weight_.width_;
```
初始化設定 `ppi` 和 `idx` ，以及最內部迴圈的迭代次數。**`ppi` 的值現在也被設定好了。**

```c
        for (uint64_t y = 0; y < out_.height_; y++) {
            for (uint64_t x = 0; x < out_.width_; x++) {
```
根據 cnn layer 的高和寬進行迭代，取變數為 `y` 和 `x`。

```c
                const float_t * ppw = pw;
                float_t sum = (float_t)0;
                uint64_t wx = 0, widx = 0;
```
設定變數 `ppw` 為 pw 。每次最內部迴圈迭代時都會初始化。此外，其他變數也會初始化為 0 。

```c
                for (uint64_t wyx = 0; wyx < inner_loop_iter; wyx++) {
```
最內部迴圈的迭代次數為 `inner_loop_iter` ，實際上是寬乘高。

```c
                    sum += *ppw++ * ppi[widx];
```
這邊會取 `ppw` 的資料和 `ppi` 的資料並且遞增。 `ppi` 透過 index 取得資料，但是 `ppw` 透過指標，因此 `ppw` 需要初始化， `ppi` 則需要透過初始化 `widx` 。

```c
                    wx++;
                    widx++;
                    if (wx == weight_.width_)
                    {
                        wx = 0;
                        widx += const1;
                    }
                }
                pa[idx++] += sum;
                ppi += w_stride_;
            }
            ppi += const2;
        }
    }
```
剩下的部分在處理 `ppi` 和 `widx` 的資料。

### circuit

真正重要的是 `sum += *ppw++ * ppi[widx];` 基本上在進行一個內積運算。所以需要把 sum 對應到 result array ， ppw 的資料對應到 A array ， ppi 的資料對應到 B array 。每次做福點數相乘都是將資料寫入對應的陣列並且等待結果。

整個 sum 會在最內部迴圈迭代完成之後需要 result array 資料。而最內部迴圈在迭代過程中會固定執行 `inner_loop_iter` 次，因為迴圈條件沒有被修改。可以知道矩陣乘法的次數，進而推論出所需的向量長度。

## fully_connected_layer_forward_propagation

```c
    float_t *in = input->in_ptr_;
    float_t *a = entry->base.a_ptr_;
    float_t *W = entry->base._W;
    float_t *b = entry->base._b;
    float_t *out = entry->base.out_ptr_;
    input->in_ptr_ = out;
    input->in_size_ = entry->base.out_size_;

    uint64_t total_size = entry->base.out_size_;
```
設定基本參數。

```c
    for (uint64_t i = 0; i < total_size; i++) {
```
設定迭代次數為 layer 的大小。

```c
        a[i] = (float_t)0;
```
初始化 a 為 0 。

```c
        for (uint64_t c = 0; c < entry->base.in_size_; c++)
            a[i] += W[i*entry->base.in_size_ + c] * in[c];
```
對 W 和 in 做內積並遞增到 a 。

```c
        if (entry->has_bias_)
            a[i] += b[i];
    }
```
加上誤差值。

```c
    for (uint64_t i = 0; i < total_size; i++)
        out[i] = entry->base.activate(a, i, entry->base.out_size_);
```