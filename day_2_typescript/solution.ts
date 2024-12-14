type ReactorReport = number[];

function parseInput(txt: string): ReactorReport[] {
  const reports = []
  for(const line of txt.split(/[\n,\r]/g)){
    const report: ReactorReport = line.split(' ').map(x => Number(x))
    reports.push(report)
  }
  return reports;
}

function isReportSafe(report: ReactorReport): boolean {
  if(report.length < 2){
    return false;
  }


  const shouldIncrease = report.at(0)! < report.at(-1)!

  for(let i = 1; i < report.length; i += 1){
    const diff = report[i] - report[i-1];

    // Not safe because too big of a jump between two adjacent levels
    if(diff === 0 || Math.abs(diff) > 3) {
      return false;
    }

    // Not safe because not all increasing
    if(shouldIncrease && diff < 0){
      return false;
    }

    // Not safe because not all decreasing
    if(!shouldIncrease && diff > 0) {
      return false
    }

  }

  return true
}

function part1Solution(reports: ReactorReport[]): number {
  return reports.reduce<number>((safeCount, report) => {
    return isReportSafe(report) ? safeCount + 1 : safeCount
  }, 0)
}

function part2Solution(reports: ReactorReport[]): number {
  return reports.reduce<number>((safeCount, report) => {
    const reportVariants = report.reduce<ReactorReport[]>((variants, _levels, idx) => {
      const variant = report.slice(0, idx).concat(report.slice(idx + 1, report.length))
      return variants.concat([variant])
    }, [])

    return reportVariants.some(reportVariant => isReportSafe(reportVariant)) ? safeCount + 1 : safeCount
  }, 0) 
}

const file = Bun.file(Bun.argv[2])

const txt = await file.text();
console.log(part2Solution(parseInput(txt)))