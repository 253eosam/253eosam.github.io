export interface ResumeLink {
  label: string;
  url: string;
}

export interface ResumeContentBlock {
  text?: string;
  label?: string;
  items?: string[];
  link?: ResumeLink;
}

export interface ResumeProfile {
  name: string;
  profileImage?: string;
  role: string;
  email: string;
  links: ResumeLink[];
  introduction: string;
  highlights?: string[];
}

export interface ResumeProjectIssue {
  problem?: ResumeContentBlock;
  strategy?: ResumeContentBlock;
  execution?: ResumeContentBlock;
  impact?: ResumeContentBlock;
  retrospective?: ResumeContentBlock;
}

export type ResumeProjectPresentation = 'story' | 'compact';

export interface ResumeProject {
  name: string;
  url?: string;
  partialLinkLabel?: string;
  presentation: ResumeProjectPresentation;
  summary?: string;
  contribution?: string;
  techStack?: string[];
  team?: string;
  issues?: ResumeProjectIssue[];
  details?: ResumeContentBlock[];
}

export interface ResumeExperience {
  company: string;
  logo?: string;
  role: string;
  department?: string;
  startDate: string;
  endDate?: string;
  isCurrent?: boolean;
  employmentType?: string;
  description?: string;
  projects: ResumeProject[];
}

export interface ResumeCertification {
  name: string;
  organization: string;
  date: string;
}

export interface ResumeEducation {
  institution: string;
  major?: string;
  period: string;
  degree?: string;
}

export interface ResumeActivity {
  name: string;
  organization: string;
  period: string;
  description?: string;
  details?: string[];
  link?: ResumeLink;
}

export interface ResumeData {
  profile: ResumeProfile;
  skills: string[];
  experience: ResumeExperience[];
  certifications: ResumeCertification[];
  education: ResumeEducation[];
  activities: ResumeActivity[];
}
