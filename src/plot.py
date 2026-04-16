#!/usr/bin/env python3
"""
Generate box-and-dot plots for the coding AI language benchmark.

Usage:
    python plot.py results/results.json [--codex gemini]

Defaults to a sibling figures/ directory when given .../results/results.json.
"""

import argparse
import json
import sys
from pathlib import Path

import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np
import pandas as pd

# ── Style ──────────────────────────────────────────────────────────────────

plt.rcParams.update({
    "figure.facecolor": "white",
    "axes.facecolor": "white",
    "axes.grid": True,
    "grid.alpha": 0.3,
    "font.size": 12,
})

# Language groups with display order.
# Each group is separated by a gap in the plot.
LANG_GROUPS = [
    # Dynamic
    ["ruby", "python", "javascript", "perl", "lua"],
    # Dynamic + type checker
    ["ruby/steep", "python/mypy"],
    # Static (imperative)
    ["typescript", "go", "rust", "c", "java"],
    # Functional
    ["scheme", "ocaml", "haskell"],
]
LANG_ORDER = [lang for group in LANG_GROUPS for lang in group]
GROUP_GAP = 0.8  # extra space between groups

# Display names for axis labels
LANG_LABELS = {
    "ruby": "Ruby",
    "python": "Python",
    "javascript": "JavaScript",
    "perl": "Perl",
    "lua": "Lua",
    "scheme": "Scheme",
    "ruby/steep": "Ruby/Steep",
    "python/mypy": "Python/mypy",
    "typescript": "TypeScript",
    "go": "Go",
    "rust": "Rust",
    "c": "C",
    "java": "Java",
    "ocaml": "OCaml",
    "haskell": "Haskell",
}

# Colour palette
# Dynamic: warm (red/orange/yellow), Static: cool (blue/teal), Functional: grey/purple
PALETTE = {
    # Dynamic (warm)
    "ruby":        "#CC342D",
    "python":      "#E06030",
    "javascript":  "#E8A020",
    "perl":        "#D46B1A",
    "lua":         "#C44040",
    # Dynamic + type checker (warm, lighter)
    "ruby/steep":  "#E8A0A0",
    "python/mypy": "#F0C090",
    # Static (cool)
    "typescript":  "#2266BB",
    "go":          "#00A0C8",
    "rust":        "#3088B8",
    "c":           "#2850A0",
    "java":        "#50B0D0",
    # Functional (grey/purple)
    "scheme":      "#888888",
    "ocaml":       "#A0A0A0",
    "haskell":     "#606060",
}
DEFAULT_COLOUR = "#999999"


# ── Load data ─────────────────────────────────────────────────────────────

def record_codex(record):
    """Return the codex name for a result record."""
    codex = record.get("codex")
    if codex:
        return codex
    if "v1_claude" in record or "v2_claude" in record:
        return "claude"
    return "unknown"


def phase_metrics(record, phase):
    """Return metrics for a phase, supporting new and legacy schemas."""
    metrics = record.get(f"{phase}_metrics")
    if isinstance(metrics, dict):
        return metrics

    codex = record_codex(record)
    legacy = record.get(f"{phase}_{codex}")
    if isinstance(legacy, dict):
        return legacy

    fallback = record.get(f"{phase}_claude")
    if isinstance(fallback, dict):
        return fallback

    return {}


def load_results(path, codex=None):
    """Load results.json and return a flat DataFrame."""
    with open(path, encoding="utf-8") as f:
        raw = json.load(f)

    selected_codex = codex.lower() if codex else None
    rows = []
    for r in raw:
        row_codex = record_codex(r)
        if selected_codex and selected_codex != "all" and row_codex != selected_codex:
            continue

        lang = r["language"]
        trial = r["trial"]
        v1m = phase_metrics(r, "v1")
        v2m = phase_metrics(r, "v2")
        rows.append({
            "codex": row_codex,
            "language": lang,
            "trial": trial,
            "v1_time": r.get("v1_time", 0),
            "v2_time": r.get("v2_time", 0),
            "total_time": r.get("v1_time", 0) + r.get("v2_time", 0),
            "v1_loc": r.get("v1_loc", 0),
            "v2_loc": r.get("v2_loc", 0),
            "v1_cost": v1m.get("cost_usd", 0),
            "v2_cost": v2m.get("cost_usd", 0),
            "total_cost": v1m.get("cost_usd", 0) + v2m.get("cost_usd", 0),
            "v1_turns": v1m.get("num_turns", 0),
            "v2_turns": v2m.get("num_turns", 0),
            "total_turns": v1m.get("num_turns", 0) + v2m.get("num_turns", 0),
            "v1_output_tokens": v1m.get("output_tokens", 0),
            "v2_output_tokens": v2m.get("output_tokens", 0),
            "v1_cache_read": v1m.get("cache_read_tokens", 0),
            "v2_cache_read": v2m.get("cache_read_tokens", 0),
            "v1_tps": v1m.get("output_tokens", 0) / r.get("v1_time", 1) if r.get("v1_time", 0) > 0 else 0,
            "v2_tps": v2m.get("output_tokens", 0) / r.get("v2_time", 1) if r.get("v2_time", 0) > 0 else 0,
            "total_tps": (v1m.get("output_tokens", 0) + v2m.get("output_tokens", 0)) / (r.get("v1_time", 0) + r.get("v2_time", 0)) if (r.get("v1_time", 0) + r.get("v2_time", 0)) > 0 else 0,
        })

    return pd.DataFrame(rows)


def codex_label(codex):
    if not codex or codex == "all":
        return "All Codexes"
    return codex.capitalize()


def plot_title(codex, text):
    return f"{text} — {codex_label(codex)}"


# ── Plotting helper ───────────────────────────────────────────────────────

def _compute_positions(languages):
    """Compute x positions with gaps between groups."""
    # Build a set for quick lookup of group boundaries
    group_starts = set()
    pos = 0
    for group in LANG_GROUPS:
        for lang in group:
            if lang in languages:
                group_starts.add(lang)
                break

    positions = []
    x = 0
    for lang in languages:
        if lang in group_starts and positions:
            x += GROUP_GAP
        positions.append(x)
        x += 1
    return positions


def _auto_ylim(all_values):
    """Return a y-axis upper limit that clips extreme outliers, or None."""
    if len(all_values) == 0:
        return None
    q75 = np.percentile(all_values, 75)
    q25 = np.percentile(all_values, 25)
    iqr = q75 - q25
    fence = q75 + 2.0 * iqr
    ymax = max(all_values)
    if ymax > fence and fence > 0:
        # Add some padding above the fence
        return fence * 1.08
    return None


def boxdot(ax, df, value_col, *, ylabel, title, clip=True):
    """Draw a box plot with overlaid dot (strip) plot.

    clip: True for auto IQR clipping, False for no clipping,
          or a number for a fixed upper limit.
    """
    languages = [l for l in LANG_ORDER if l in df["language"].unique()]
    for l in sorted(df["language"].unique()):
        if l not in languages:
            languages.append(l)

    data = [df.loc[df["language"] == lang, value_col].values for lang in languages]
    colours = [PALETTE.get(lang, DEFAULT_COLOUR) for lang in languages]
    labels = [LANG_LABELS.get(lang, lang) for lang in languages]
    positions = _compute_positions(languages)

    # Determine y-axis clipping
    all_values = np.concatenate(data)
    if isinstance(clip, (int, float)) and not isinstance(clip, bool):
        ylim_upper = clip
    elif clip:
        ylim_upper = _auto_ylim(all_values)
    else:
        ylim_upper = None

    bp = ax.boxplot(
        data,
        positions=positions,
        widths=0.5,
        patch_artist=True,
        showfliers=False,
        zorder=2,
    )
    for patch, colour in zip(bp["boxes"], colours):
        patch.set_facecolor(colour)
        patch.set_alpha(0.35)
    for element in ("whiskers", "caps", "medians"):
        for line in bp[element]:
            line.set_color("#333333")
            line.set_linewidth(1.2)

    rng = np.random.default_rng(42)
    clipped_points = []  # (x, actual_value, display_y)
    for i, (lang, pos, vals) in enumerate(zip(languages, positions, data)):
        jitter = rng.uniform(-0.15, 0.15, size=len(vals))
        for j, v in enumerate(vals):
            x = pos + jitter[j]
            if ylim_upper is not None and v > ylim_upper:
                # Draw at the top edge and record for annotation
                clipped_points.append((x, v, ylim_upper * 0.97))
            else:
                ax.scatter(
                    x, v,
                    color=PALETTE.get(lang, DEFAULT_COLOUR),
                    edgecolors="white",
                    linewidths=0.5,
                    s=50,
                    alpha=0.85,
                    zorder=3,
                )

    # Annotate clipped points
    if ylim_upper is not None and clipped_points:
        ax.set_ylim(top=ylim_upper)
        for x, actual, display_y in clipped_points:
            ax.scatter(
                x, display_y,
                marker="^",
                color="#CC0000",
                s=40,
                zorder=4,
            )
            ax.annotate(
                f"{actual:.0f}",
                xy=(x, display_y),
                xytext=(0, 10),
                textcoords="offset points",
                fontsize=8,
                fontweight="bold",
                ha="center",
                va="bottom",
                color="#CC0000",
            )

    ax.set_ylim(bottom=0)
    ax.set_xticks(positions)
    ax.set_xticklabels(labels, rotation=30, ha="right")
    ax.set_ylabel(ylabel)
    ax.set_title(title, pad=15)


def save(fig, outdir, name):
    path = outdir / f"{name}.png"
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print(f"  saved {path}")


# ── Main ──────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("json", type=Path, help="Path to results.json")
    parser.add_argument(
        "-o", "--outdir", type=Path, default=None,
        help="Output directory (default: sibling figures/ if input is under results/)",
    )
    parser.add_argument(
        "--codex",
        default=None,
        help="Filter to a codex (e.g. claude, gemini, all)",
    )
    args = parser.parse_args()

    if not args.json.exists():
        sys.exit(f"Error: {args.json} not found")

    if args.outdir is None:
        if args.json.parent.name == "results":
            args.outdir = args.json.parent.parent / "figures"
        else:
            args.outdir = Path("figures")

    args.outdir.mkdir(parents=True, exist_ok=True)
    df = load_results(args.json, codex=args.codex)
    if df.empty:
        sys.exit("Error: no matching results found")

    # ── Total ─────────────────────────────────────────────────────────────
    print("Generating total plots …")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "total_time", ylabel="Time (s)",
           title=plot_title(args.codex, "Time to Generate (v1+v2)"), clip=300)
    save(fig, args.outdir, "total_time")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "total_cost", ylabel="Cost (USD)",
           title=plot_title(args.codex, "Cost to Generate (v1+v2)"), clip=False)
    ax.yaxis.set_major_formatter(ticker.FormatStrFormatter("$%.2f"))
    save(fig, args.outdir, "total_cost")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v2_loc", ylabel="Lines of code",
           title=plot_title(args.codex, "Lines of Code Generated (v2)"), clip=False)
    save(fig, args.outdir, "total_lines")

    # ── v1 ───────────────────────────────────────────────────────────
    print("Generating v1 plots …")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v1_time", ylabel="Time (s)",
           title=plot_title(args.codex, "Time to Generate v1"), clip=200)
    save(fig, args.outdir, "v1_time")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v1_cost", ylabel="Cost (USD)",
           title=plot_title(args.codex, "Cost to Generate v1"), clip=False)
    ax.yaxis.set_major_formatter(ticker.FormatStrFormatter("$%.2f"))
    save(fig, args.outdir, "v1_cost")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v1_loc", ylabel="Lines of code",
           title=plot_title(args.codex, "Lines of Code Generated (v1)"), clip=False)
    save(fig, args.outdir, "v1_lines")

    # ── v2 ───────────────────────────────────────────────────────────
    print("Generating v2 plots …")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v2_time", ylabel="Time (s)",
           title=plot_title(args.codex, "Time to Generate v2"), clip=150)
    save(fig, args.outdir, "v2_time")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v2_cost", ylabel="Cost (USD)",
           title=plot_title(args.codex, "Cost to Generate v2"), clip=False)
    ax.yaxis.set_major_formatter(ticker.FormatStrFormatter("$%.2f"))
    save(fig, args.outdir, "v2_cost")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v2_loc", ylabel="Lines of code",
           title=plot_title(args.codex, "Lines of Code Generated (v2)"), clip=False)
    save(fig, args.outdir, "v2_lines")

    # ── Turns ─────────────────────────────────────────────────────────────
    print("Generating turn count plots …")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v1_turns", ylabel="Turns",
           title=plot_title(args.codex, "Agent Turns (v1)"), clip=25)
    save(fig, args.outdir, "v1_turns")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v2_turns", ylabel="Turns",
           title=plot_title(args.codex, "Agent Turns (v2)"), clip=25)
    save(fig, args.outdir, "v2_turns")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "total_turns", ylabel="Turns",
           title=plot_title(args.codex, "Agent Turns (v1+v2)"), clip=45)
    save(fig, args.outdir, "total_turns")

    # ── TPS ───────────────────────────────────────────────────────────────
    print("Generating Tokens Per Second (TPS) plots …")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v1_tps", ylabel="Tokens Per Second",
           title=plot_title(args.codex, "Tokens Per Second (v1)"), clip=150)
    save(fig, args.outdir, "v1_tps")

    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "v2_tps", ylabel="Tokens Per Second",
           title=plot_title(args.codex, "Tokens Per Second (v2)"), clip=150)
    save(fig, args.outdir, "v2_tps")
    
    fig, ax = plt.subplots(figsize=(10, 5))
    boxdot(ax, df, "total_tps", ylabel="Tokens Per Second",
           title=plot_title(args.codex, "Tokens Per Second (v1+v2)"), clip=150)
    save(fig, args.outdir, "total_tps")

    # ── Scatter: Time vs Cost ─────────────────────────────────────────────
    print("Generating scatter plots …")

    for time_col, cost_col, suffix, title in [
        ("total_time", "total_cost", "total", "Time vs Cost (v1+v2)"),
        ("v1_time", "v1_cost", "v1", "Time vs Cost v1"),
        ("v2_time", "v2_cost", "v2", "Time vs Cost v2"),
    ]:
        fig, ax = plt.subplots(figsize=(8, 6))
        for lang in LANG_ORDER:
            sub = df[df["language"] == lang]
            if sub.empty:
                continue
            ax.scatter(
                sub[time_col], sub[cost_col],
                color=PALETTE.get(lang, DEFAULT_COLOUR),
                edgecolors="white",
                linewidths=0.5,
                s=60,
                alpha=0.85,
                label=LANG_LABELS.get(lang, lang),
                zorder=3,
            )
        ax.set_xlabel("Time (s)")
        ax.set_ylabel("Cost (USD)")
        ax.set_xlim(left=0)
        ax.set_ylim(bottom=0)
        ax.yaxis.set_major_formatter(ticker.FormatStrFormatter("$%.2f"))
        ax.set_title(plot_title(args.codex, title))
        ax.legend(
            fontsize=8, ncol=3, loc="upper left",
            framealpha=0.8, borderpad=0.5,
        )
        save(fig, args.outdir, f"{suffix}_time_vs_cost")

    # ── Scatter: Time vs LOC ──────────────────────────────────────────────
    print("Generating time vs LOC scatter plots …")

    for time_col, loc_col, suffix, title in [
        ("total_time", "v2_loc", "total", "Time vs LOC (v1+v2)"),
        ("v1_time", "v1_loc", "v1", "Time vs LOC v1"),
        ("v2_time", "v2_loc", "v2", "Time vs LOC v2"),
    ]:
        fig, ax = plt.subplots(figsize=(8, 6))
        for lang in LANG_ORDER:
            sub = df[df["language"] == lang]
            if sub.empty:
                continue
            ax.scatter(
                sub[time_col], sub[loc_col],
                color=PALETTE.get(lang, DEFAULT_COLOUR),
                edgecolors="white",
                linewidths=0.5,
                s=60,
                alpha=0.85,
                label=LANG_LABELS.get(lang, lang),
                zorder=3,
            )
        ax.set_xlabel("Time (s)")
        ax.set_ylabel("Lines of code")
        ax.set_xlim(left=0)
        ax.set_ylim(bottom=0)
        ax.set_title(plot_title(args.codex, title))
        ax.legend(
            fontsize=8, ncol=3, loc="upper left",
            framealpha=0.8, borderpad=0.5,
        )
        save(fig, args.outdir, f"{suffix}_time_vs_loc")

    print("Done.")


if __name__ == "__main__":
    main()
