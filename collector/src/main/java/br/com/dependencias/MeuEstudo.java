package br.com.dependencias;

import br.com.metricminer2.MetricMiner2;
import br.com.metricminer2.RepositoryMining;
import br.com.metricminer2.Study;
import br.com.metricminer2.persistence.csv.CSVFile;
import br.com.metricminer2.scm.GitRepository;
import br.com.metricminer2.scm.commitrange.Commits;

public class MeuEstudo implements Study {

    private final String projectPath;
    private final String csvPath;

    public MeuEstudo(String projectPath, String csvPath) {
        this.projectPath = projectPath;
        this.csvPath = csvPath;
    }

    public static void main(String[] args) {
        new MetricMiner2().start(new MeuEstudo(args[0], args[1]));
    }

    @Override
    public void execute() {

        new RepositoryMining()
                .in(GitRepository.singleProject(projectPath))
                .through(Commits.all())
                .startingFromTheBeginning()
                .process(new ContaDependenciaLogica(), new CSVFile(csvPath))
                .withThreads(3)
                .mine();

    }

}
