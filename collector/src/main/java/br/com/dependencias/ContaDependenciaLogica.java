package br.com.dependencias;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import br.com.metricminer2.domain.Commit;
import br.com.metricminer2.domain.Modification;
import br.com.metricminer2.persistence.PersistenceMechanism;
import br.com.metricminer2.scm.CommitVisitor;
import br.com.metricminer2.scm.SCMRepository;
import org.apache.log4j.Logger;

public class ContaDependenciaLogica implements CommitVisitor {

    private static final Logger logger = Logger.getLogger(ContaDependenciaLogica.class);

    @Override
    public void process(SCMRepository repo,
            Commit commit,
            PersistenceMechanism writer) {

        List<String> files = new ArrayList<String>();
        for (Modification m : commit.getModifications()) {
            if (m.fileNameEndsWith("gif") || m.fileNameEndsWith("jpeg")
                    || m.fileNameEndsWith("jpg") || m.fileNameEndsWith("png")) {
                continue;
            }
            files.add(m.getFileName());
        }

        if (!files.isEmpty() && commit.getModifications().size() <= 30) {
            String allFiles = String.join(",", files);
            String result
                    = repo.getLastDir() + ";"
                    + commit.getAuthor().getName() + ";"
                    + commit.getHash() + ";"
                    + new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(commit.getDate().getTime()) + ";"
                    + allFiles;

            writer.write(result);
        } else {
            logger.info("skipped commit " + commit.getHash());
        }

    }

    @Override
    public String name() {
        return "conta-dependencias";
    }

}
