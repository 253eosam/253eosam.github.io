import type { ResumeContentBlock, ResumeData, ResumeExperience, ResumeProject } from '../types/resume';

interface ResumeInlineLinkViewModel {
  before: string;
  label: string;
  url: string;
  after: string;
}

export interface ResumeContentViewModel {
  text?: string;
  label?: string;
  items: string[];
  inlineLink?: ResumeInlineLinkViewModel;
}

export interface ResumeNarrativeRowViewModel {
  label: '문제정의' | '해결전략' | '주요 실행' | '성과' | '회고';
  content: ResumeContentViewModel;
  tone?: 'default' | 'retrospective';
}

export interface ResumeNarrativeBlockViewModel {
  index: number;
  rows: ResumeNarrativeRowViewModel[];
}

export interface ResumeProjectFactViewModel {
  label: '프로젝트 설명' | '팀 구성' | '기여도' | '기술';
  text?: string;
  techStack?: string[];
}

export interface ResumeProjectTitleViewModel {
  text: string;
  url?: string;
  inlineLink?: ResumeInlineLinkViewModel;
}

export interface ResumeProjectViewModel {
  title: ResumeProjectTitleViewModel;
  presentation: ResumeProject['presentation'];
  facts: ResumeProjectFactViewModel[];
  narratives: ResumeNarrativeBlockViewModel[];
  details: ResumeContentViewModel[];
}

export interface ResumeExperienceViewModel extends Omit<ResumeExperience, 'projects'> {
  projects: ResumeProjectViewModel[];
}

export interface ResumeViewModel extends Omit<ResumeData, 'experience'> {
  experience: ResumeExperienceViewModel[];
}

const splitLinkedText = (text: string, label: string) => {
  const index = text.indexOf(label);

  if (index === -1) {
    return null;
  }

  return {
    before: text.slice(0, index),
    after: text.slice(index + label.length),
  };
};

const mapInlineLink = (text: string, label: string, url: string): ResumeInlineLinkViewModel | undefined => {
  const split = splitLinkedText(text, label);

  if (!split) {
    return undefined;
  }

  return {
    before: split.before,
    label,
    url,
    after: split.after,
  };
};

const mapContentBlock = (block?: ResumeContentBlock): ResumeContentViewModel | null => {
  if (!block) {
    return null;
  }

  const text = block.text?.trim() || undefined;
  const items = block.items ?? [];

  if (!text && items.length === 0) {
    return null;
  }

  const inlineLink = text && block.link ? mapInlineLink(text, block.link.label, block.link.url) : undefined;

  return {
    text,
    label: block.label,
    items,
    inlineLink,
  };
};

const mapProjectTitle = (project: ResumeProject): ResumeProjectTitleViewModel => {
  if (project.url && project.partialLinkLabel) {
    const inlineLink = mapInlineLink(project.name, project.partialLinkLabel, project.url);

    if (inlineLink) {
      return {
        text: project.name,
        inlineLink,
      };
    }
  }

  return {
    text: project.name,
    url: project.url,
  };
};

const mapProjectFacts = (project: ResumeProject): ResumeProjectFactViewModel[] => {
  const facts: ResumeProjectFactViewModel[] = [];

  if (project.summary) {
    facts.push({ label: '프로젝트 설명', text: project.summary });
  }

  if (project.team) {
    facts.push({ label: '팀 구성', text: project.team });
  }

  if (project.contribution) {
    facts.push({ label: '기여도', text: project.contribution });
  }

  if (project.techStack && project.techStack.length > 0) {
    facts.push({ label: '기술', techStack: project.techStack });
  }

  return facts;
};

const mapProjectNarratives = (project: ResumeProject): ResumeNarrativeBlockViewModel[] => {
  if (project.presentation !== 'story' || !project.issues) {
    return [];
  }

  return project.issues
    .map((issue, index) => {
      const rows: ResumeNarrativeRowViewModel[] = [];

      const problem = mapContentBlock(issue.problem);
      if (problem) {
        rows.push({ label: '문제정의', content: problem });
      }

      const strategy = mapContentBlock(issue.strategy);
      if (strategy) {
        rows.push({ label: '해결전략', content: strategy });
      }

      const execution = mapContentBlock(issue.execution);
      if (execution) {
        rows.push({ label: '주요 실행', content: execution });
      }

      const impact = mapContentBlock(issue.impact);
      if (impact) {
        rows.push({ label: '성과', content: impact });
      }

      const retrospective = mapContentBlock(issue.retrospective);
      if (retrospective) {
        rows.push({ label: '회고', content: retrospective, tone: 'retrospective' });
      }

      if (rows.length === 0) {
        return null;
      }

      return {
        index: index + 1,
        rows,
      };
    })
    .filter((block): block is ResumeNarrativeBlockViewModel => block !== null);
};

const mapProjectDetails = (project: ResumeProject): ResumeContentViewModel[] => {
  if (project.presentation !== 'compact' || !project.details) {
    return [];
  }

  return project.details
    .map((detail) => mapContentBlock(detail))
    .filter((detail): detail is ResumeContentViewModel => detail !== null);
};

const mapProject = (project: ResumeProject): ResumeProjectViewModel => ({
  title: mapProjectTitle(project),
  presentation: project.presentation,
  facts: mapProjectFacts(project),
  narratives: mapProjectNarratives(project),
  details: mapProjectDetails(project),
});

const mapExperience = (experience: ResumeExperience): ResumeExperienceViewModel => ({
  ...experience,
  projects: experience.projects.map(mapProject),
});

export const mapResumeData = (resume: ResumeData): ResumeViewModel => ({
  ...resume,
  experience: resume.experience.map(mapExperience),
});
