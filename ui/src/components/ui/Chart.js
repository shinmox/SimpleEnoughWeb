import React, {useEffect} from 'react';
import ChartD3 from './Chart.d3'

export default function ChartReact() {
    let chartRef = React.useRef();

    useEffect(() =>{
        ChartD3(chartRef.current)
    });

    return (<div ref={chartRef}/>);
}
