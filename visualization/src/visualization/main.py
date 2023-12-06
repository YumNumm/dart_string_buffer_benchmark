import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import base64


def load_from_csv(filename):
    df = pd.read_csv(filename)
    return df


def plot(df):
    plt.rcParams["font.family"] = "JetBrains Mono"
    plt.figure(0)
    plt.title("String vs StringBuffer Benchmark")
    print(df)
    # Plot
    for name, group in df.groupby("type"):
        plt.plot(group.index.get_level_values(0), group["time"], label=name)

    plt.xlabel(r"iteration count (${N}$)")
    plt.ylabel(r"time (${ms}$)")
    plt.grid()
    plt.legend()
    plt.minorticks_on()
    # save to file
    plt.savefig(
        "benchmark.png",
        dpi=600,
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
