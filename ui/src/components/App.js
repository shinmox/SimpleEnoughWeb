import ChartReact from './ui/Chart'
import Header from './ui/header/Header';
import React from 'react';
import { ThemeProvider } from '@material-ui/styles'
import theme from './ui/Theme'

export default function App() {
  return (
    <div className="App">
      <ThemeProvider theme={theme}>
        <Header />
        <ChartReact />
        <ChartReact />
        <ChartReact />
        <ChartReact />
      </ThemeProvider>
    </div>
  );
}
