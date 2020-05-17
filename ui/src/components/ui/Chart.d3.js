import * as d3 from 'd3';

const DATA = [
    {"name": "foo",    "age": 10},
    {"name": "bar",    "age": 12},
    {"name": "baz",    "age": 17},
    {"name": "qux",    "age":  8},
    {"name": "quux",   "age": 13},
    {"name": "corge",  "age": 12},
    {"name": "grault", "age": 19},
    {"name": "garply", "age": 7},
]

const MARGIN = { top: 10, bottom: 50, left: 70, right: 10}
const WIDTH = 800 - MARGIN.left - MARGIN.right;
const HEIGHT = 500 - MARGIN.top - MARGIN.bottom;

export default function D3Chart(element) {
    // CANVAS
    const svg = d3.select(element)
        .append("svg")
            .attr("width", WIDTH + MARGIN.left + MARGIN.right)
            .attr("height", HEIGHT + MARGIN.top + MARGIN.bottom)
        .append("g")
            .attr("transform", `translate(${MARGIN.left}, ${MARGIN.top})`);

    // DEFINE BAR CHARTS
    const y = d3.scaleLinear()
        .domain([
            d3.min(DATA, value => value.age) * 0.8,
            d3.max(DATA, element => element.age)])
        .range([HEIGHT, 0]);

    // NAMES
    const x = d3.scaleBand()
        .domain(DATA.map(element => element.name))
        .range([0, WIDTH])
        .padding(0.2);

    const xAxisCall = d3.axisBottom(x);
    svg.append("g")
        .attr("transform", `translate(0, ${HEIGHT})`)
        .call(xAxisCall);
    svg.append("text")
        .attr("x", WIDTH/2)
        .attr("y", HEIGHT + 40)
        .attr("text-anchor", "middle")
        .text("Name");

    // AGE
    const yAxisCall = d3.axisLeft(y);
    svg.append("g")
        .call(yAxisCall);
    svg.append("text")
        .attr("x", -HEIGHT/2)
        .attr("y", -50)
        .attr("text-anchor", "middle")
        .text("Age")
        .attr("transform", "rotate(-90)")

    // DATA
    const bars = svg
        .selectAll("rect")
        .data(DATA);
    bars.enter()
        .append("rect")
        .attr("x", value => x(value.name))
        .attr("y", value => y(value.age))
        .attr("width", x.bandwidth)
        .attr("height", value => HEIGHT - y(value.age))
        .attr("fill", "darkblue");
}
