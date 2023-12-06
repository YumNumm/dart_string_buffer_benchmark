import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import base64
import scipy.optimize as optimize
import sklearn.metrics as metrics


def load_from_csv(filename):
    df = pd.read_csv(filename)
    return df


def plot(df):
    plt.rcParams["font.family"] = "JetBrains Mono"
    plt.figure(0)
    plt.title("String vs StringBuffer Benchmark")
    print(df)
    # 同じloopの場合 平均を取る
    df = df.groupby(["type", "loop"]).mean()
    # Plot
    # x軸はloopの値
    # y軸はtimeの値
    # typeごとにplot
    popts = []
    for type in df.index.levels[0]:
        x = df.loc[type].index
        y = df.loc[type]["time"]
        # 近似直線
        x = np.array(x)
        y = np.array(y)

        def f(x, a, b):
            # 切片0の2次関数にフィッティングさせる
            return a * x**2 + b * x

        popt, _ = optimize.curve_fit(f, x, y)

        # 近似曲線の算出
        approximation_y = f(x, *popt)

        # 近似曲線の決定係数
        # TODO(YumNumm): なんか違う気がするので また今度
        # r2 = metrics.r2_score(y, approximation_y)
        # print(type, "決定係数 (R2)", r2)

        # 近似式
        print(type, "近似式", f"{popt[0]:f}x^2 + {popt[1]:f}x")

        # 近似曲線のplot
        plt.plot(x, approximation_y, label=type + " (fit)", linewidth=0.5)
        # plot
        plt.plot(x, y, label=type)

    plt.xlabel(r"iteration count (${N}$)")
    plt.ylabel(r"time (${ms}$)")
    plt.grid()
    plt.legend()
    plt.minorticks_on()
    # save to file
    plt.savefig(
        "benchmark.png",
        dpi=300,
    )


def generate_html():
    """
    Visualize benchmark png as html
    """
    base64Image = base64.b64encode(open("benchmark.png", "rb").read()).decode()
    imageHtml = '<img src="data:image/png;base64,{}">'.format(base64Image)
    html = """
    <html>
        <head>
            <title>Benchmark</title>
        </head>
        <style>
            img {{
                display: block;
                margin-left: auto;
                margin-right: auto;
                width: 50%;
                height: auto;
            }}
        </style>
        <body>
            <h1>Benchmark</h1>
            {}
        </body>
    </html>
    """.format(
        imageHtml
    )
    with open("benchmark.html", "w") as f:
        f.write(html)


def main():
    try:
        df = load_from_csv("benchmark.csv")
    except:
        print("Error: benchmark.csv not found")
        return
    plot(df)
    generate_html()


if __name__ == "__main__":
    main()
